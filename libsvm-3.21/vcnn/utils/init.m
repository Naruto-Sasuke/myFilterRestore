function init(flag)
    % flag: 0 for training, 1 for testing
    global config;
    
    config.GEN_OUTPUT = @gen_output_copy;
    if strcmp(config.compute_device, 'GPU')
        init_gpu(1);
        config.NEW_MEM = @to_gpu;
        config.IM2COL = @im2col_gpu;
    end
    
    if strcmp(config.nonlinearity, 'relu')
        config.NONLINEARITY = @relu;
    end
    

    if strcmp(config.output_activation, 'nil')
        config.OUT_ACT = @nonlinearity_nil;
    end
    

    if strcmp(config.cost_function, 'L2 norm')
        config.COST_FUN = @L2_norm;
    end
    
    config.cost = 0;
    config.misc.current_layer = 1;
    
    % 初始化权值并计算统计量
    r = config.weight_range;    
    conv_layer_c = 0;
    layer_num = length(config.forward_pass_scheme)-1;
    config.layer_num = layer_num;
    config.feature_map_sizes = {};
    config.weights = {};
    for idx = 1:layer_num
        %第一层特殊化处理
        if idx == 1
            conv_layer_c = conv_layer_c + 1;
            config.feature_map_sizes{idx} = [config.input_size(1)-config.kernel_size(1,1)+1 config.input_size(2)-config.kernel_size(1,2)+1 ...
                                             config.conv_hidden_size(conv_layer_c)];
            % hard code here for now        
            if strcmp(config.forward_pass_scheme{idx}, 'conv_v')
                config.weights{idx} = config.NEW_MEM(randn(config.feature_map_sizes{idx}(3), ...
                                              config.kernel_size(conv_layer_c, 1)*config.kernel_size(conv_layer_c, 2)*config.chs)*r);
                if config.normalize_init_weights
                    config.weights{idx} = config.weights{idx} / sqrt(config.kernel_size(conv_layer_c, 1) * config.kernel_size(conv_layer_c, 2) * config.conv_hidden_size(conv_layer_c));
                end
            end
        elseif strcmp(config.forward_pass_scheme{idx}, 'conv_v')
            conv_layer_c = conv_layer_c + 1;
            config.feature_map_sizes{idx} = [config.feature_map_sizes{idx-1}(1)-config.kernel_size(conv_layer_c,1)+1 ...
                                             config.feature_map_sizes{idx-1}(2)-config.kernel_size(conv_layer_c,2)+1 ...
                                             config.conv_hidden_size(conv_layer_c)];
            config.weights{idx} = config.NEW_MEM(randn(config.feature_map_sizes{idx}(3), ...
                                          config.kernel_size(conv_layer_c, 1)*config.kernel_size(conv_layer_c, 2)*config.feature_map_sizes{idx-1}(3))*r);
            if config.normalize_init_weights
                config.weights{idx} = config.weights{idx} / sqrt(config.kernel_size(conv_layer_c, 1) * config.kernel_size(conv_layer_c, 2) * config.conv_hidden_size(conv_layer_c));
            end
        elseif strcmp(config.forward_pass_scheme{idx}, 'conv_f')
            conv_layer_c = conv_layer_c + 1;
            if idx == layer_num
                config.weights{idx} = config.NEW_MEM(randn(config.kernel_size(conv_layer_c, 1)*config.kernel_size(conv_layer_c, 2)*config.output_size(3), config.conv_hidden_size(conv_layer_c-1))*r);
                if config.normalize_init_weights
                    config.weights{idx} = config.weights{idx} / sqrt(config.kernel_size(conv_layer_c, 1) * config.kernel_size(conv_layer_c, 2) * size(config.weights{idx}, 1));
                end
                config.GEN_OUTPUT = @gen_output_from_conv_f;
            else
                fprintf('in init(): conv_f layer in the hidden layer not supported yet.\n');
            end
         end

    end
    
    % 初始化偏置
    for idx = 1:layer_num-1
        config.weights{idx+layer_num} = config.NEW_MEM(zeros(config.feature_map_sizes{idx}(3), 1)+0.01);
    end
    if strcmp(config.forward_pass_scheme{layer_num}, 'conv_f')
        config.weights{layer_num*2} = config.NEW_MEM(zeros(size(config.weights{layer_num}, 1), 1)+0.05);
    else
        config.weights{layer_num*2} = config.NEW_MEM(zeros(config.output_size(3), 1)+0.05);
    end
    
    % 分配内存
    reset_mem();
    input_mem();
    if strcmp(config.forward_pass_scheme{2}, 'conv_v')
        conv2conv_mem(1);
    end
    for m = 2:layer_num
        % 只要存在conv，则进行conv_mem
        % 并且根据下一层的具体类型进行再次的mem
        % conv_v:conv2conv_mem;   conv_f的下一层是out，故有conv2out_mem
        if strfind(config.forward_pass_scheme{m}, 'conv')
            conv_mem(m);
            if strcmp(config.forward_pass_scheme{m+1}, 'out')
                conv2out_mem();
            elseif strcmp(config.forward_pass_scheme{m+1}, 'conv_v')
                conv2conv_mem(m);
            end
        end
    end
    
    % 建立流水线
    config.pipeline_forward = {};
    config.pipeline_forward{1} = @input2conv;
    conv_layer_c = 1;
    for idx = 1:layer_num
        if strfind(config.forward_pass_scheme{idx}, 'conv')
            conv_layer_c = conv_layer_c + 1;
            % 前向传播
            config.pipeline_forward{length(config.pipeline_forward)+1} = @conv_forward;

            if strcmp(config.forward_pass_scheme{idx+1}, 'conv_v')
                config.pipeline_forward{length(config.pipeline_forward)+1} = @nonlinearity;
                if config.kernel_size(conv_layer_c, 1) == 1 && config.kernel_size(conv_layer_c, 2) == 1
                    config.pipeline_forward{length(config.pipeline_forward)+1} = @conv2conv1by1;
                else
                    config.pipeline_forward{length(config.pipeline_forward)+1} = @conv2conv;
                end
            elseif strcmp(config.forward_pass_scheme{idx+1}, 'conv_f')
                config.pipeline_forward{length(config.pipeline_forward)+1} = @nonlinearity;
                config.pipeline_forward{length(config.pipeline_forward)+1} = @conv2conv_f;
            elseif strcmp(config.forward_pass_scheme{idx+1}, 'out')  
                if strcmp(config.forward_pass_scheme{idx}, 'conv_f')   % 倒数第二层
                    config.pipeline_forward{length(config.pipeline_forward)+1} = @conv2out;
                    config.pipeline_forward{length(config.pipeline_forward)+1} = @out_forward;
                else
                    % conv_f只能是conv层的输出层
                    fprintf('in init(): currently only support conv_f as the output conv layer.\n');
                end
            end

        end
    end
    
    config.SCALE_INPUT = @scale_input_nil;
    config.SCALE_OUTPUT = @scale_output_nil;
    
    if flag ~= 0
        return;
    end

    config.EXPAND_DELTA_OUT = @expand_delta_out_nil;      % 特殊
    if strcmp(config.nonlinearity, 'relu')
        config.DERI_NONLINEARITY = @deri_relu;   
    end
    
    if strcmp(config.output_activation, 'nil')
        config.DERI_OUT_ACT = @deri_nonlinearity_nil; 
    end
    
    if strcmp(config.cost_function, 'L2 norm')
        config.DERI_COST_FUN = @deri_L2_norm;     
    end
    
    % 特殊操作？？
    for m = 2:layer_num        
        if strcmp(config.forward_pass_scheme{m}, 'conv_v')            
            if strfind(config.forward_pass_scheme{m}, 'conv')
                conv_layer_id = get_conv_layer_idx_from_layer_idx(m);
                if config.kernel_size(conv_layer_id, 1) ~= 1 && config.kernel_size(conv_layer_id, 2) ~= 1
                    convBconv_mem(m);
                end
            end        
        end
    end
    
    % 建立反向传播流水线
    config.pipeline_backprop = {};
    config.pipeline_backprop{1} = @out_backprop;
    % 到最后2层时要特殊操作。
    for idx = layer_num+1:-1:3
        if strcmp(config.forward_pass_scheme{idx}, 'out')
            if strcmp(config.forward_pass_scheme{idx-1}, 'conv_f')
                config.EXPAND_DELTA_OUT = @expand_delta_out_for_conv_f;
                config.pipeline_backprop{length(config.pipeline_backprop)+1} = @outBconv;
                config.pipeline_backprop{length(config.pipeline_backprop)+1} = @conv_backprop;
            end            
        elseif strcmp(config.forward_pass_scheme{idx}, 'conv_f')
            if strcmp(config.forward_pass_scheme{idx-1}, 'conv_v')                
                config.pipeline_backprop{length(config.pipeline_backprop)+1} = @convBconv_1by1;                
            end
            config.pipeline_backprop{length(config.pipeline_backprop)+1} = @conv_backprop;
        elseif strcmp(config.forward_pass_scheme{idx}, 'conv_v')
            if strfind(config.forward_pass_scheme{idx-1}, 'conv')
                conv_layer_id = get_conv_layer_idx_from_layer_idx(idx);
                if config.kernel_size(conv_layer_id, 1) == 1 && config.kernel_size(conv_layer_id, 2) == 1
                    config.pipeline_backprop{length(config.pipeline_backprop)+1} = @convBconv_1by1;
                else
                    config.pipeline_backprop{length(config.pipeline_backprop)+1} = @convBconv;
                end
                config.pipeline_backprop{length(config.pipeline_backprop)+1} = @conv_backprop;
            end            
        end                
    end

    % 最后2层的特殊操作
    if strcmp(config.forward_pass_scheme{2}, 'conv_v') && config.kernel_size(2, 1) ~= 1 && config.kernel_size(2, 2) ~= 1
        config.pipeline_backprop{length(config.pipeline_backprop)+1} = @convBconv_last;
    end
%     if strcmp(config.forward_pass_scheme{1}, 'conv_v_mask_norm')
%         if strcmp(config.mask_for_SR, 'true')
%             config.pipeline_backprop{length(config.pipeline_backprop)+1} = @convBinput_with_mask_accel;
%         else
%             config.pipeline_backprop{length(config.pipeline_backprop)+1} = @convBinput_with_mask;
%         end
%     elseif strcmp(config.forward_pass_scheme{1}, 'conv_v_sr')
%         config.pipeline_backprop{length(config.pipeline_backprop)+1} = @convBinput_SR;

    config.pipeline_backprop{length(config.pipeline_backprop)+1} = @convBinput;

    
    if strcmp(config.optimization, 'adagrad')        
        config.his_grad = {};
        config.fudge_factor = 1e-6;
        if strcmp(config.forward_pass_scheme{1}, 'conv_v')
            config.UPDATE_WEIGHTS = @update_weights_adagrad;
            for m = 1:length(config.weights)
                config.his_grad{m} = config.NEW_MEM(zeros(size(config.weights{m})));
            end
        end
    end
end





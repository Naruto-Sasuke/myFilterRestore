function init(flag)
    % flag: 0 for training, 1 for testing
    global config;
    
    config.GEN_OUTPUT = @gen_output_copy;
    % NEW_MEM���ǽ�����ת����gpuArray
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
    
    % ��ʼ��Ȩֵ������ͳ����
    r = config.weight_range;  %��ʱr = 0.01   
    conv_layer_c = 0;
    layer_num = length(config.forward_pass_scheme)-1;
    config.layer_num = layer_num;
    config.feature_map_sizes = {};
    config.weights = {};
    for idx = 1:layer_num
        %��һ�����⻯����
        if idx == 1
            conv_layer_c = conv_layer_c + 1;
            % ��һ���feature_map_size���Ǿ�������������Ϊ���ز��size���˴�Ϊ512��
            % kernelsize��16��input_size��150�����������feature_map{1}��[135 135 512]
            config.feature_map_sizes{idx} = [config.input_size(1)-config.kernel_size(1,1)+1 config.input_size(2)-config.kernel_size(1,2)+1 ...
                                             config.conv_hidden_size(conv_layer_c)];
            % �������filters(filtersҲ��Ϊkernel)��weights�������ʼ����weight~N(0,0.01)
            % weights{1}�ǵ�һ��kernel�ĸ���*kernel{1}����ά��
            % ÿ��filter�����kernel����һ����ά�ġ�����ά��ǰһ���ͨ������
            % ��ˣ���һ���weights��Ӧ���� ���ٸ�kernel*ÿ��kernel����ά,�� 512*768��16*16*3��
            if strcmp(config.forward_pass_scheme{idx}, 'conv_v')
                config.weights{idx} = config.NEW_MEM(randn(config.feature_map_sizes{idx}(3), ...
                                              config.kernel_size(conv_layer_c, 1)*config.kernel_size(conv_layer_c, 2)*config.chs)*r);
                if config.normalize_init_weights
                    config.weights{idx} = config.weights{idx} / sqrt(config.kernel_size(conv_layer_c, 1) * config.kernel_size(conv_layer_c, 2) * config.conv_hidden_size(conv_layer_c));
                end
            end
        % �ڶ���
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
        % �����㣬�����conv_f���ʾ����û�в��ˡ�f��ʾfinal����˼��
        % �������3��ͨ����������3*(8*8*512)��Ϊ�˷���д����(3*8*8)*512
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
    
    % ��ʼ��ƫ�� [512x1   512x1  192x1]
    for idx = 1:layer_num-1
        config.weights{idx+layer_num} = config.NEW_MEM(zeros(config.feature_map_sizes{idx}(3), 1)+0.01);
    end
    % ���һ������Ϊ0.05
    if strcmp(config.forward_pass_scheme{layer_num}, 'conv_f')
        config.weights{layer_num*2} = config.NEW_MEM(zeros(size(config.weights{layer_num}, 1), 1)+0.05);
    else
        config.weights{layer_num*2} = config.NEW_MEM(zeros(config.output_size(3), 1)+0.05);
    end
    
    % �����ڴ�
    reset_mem();
    input_mem();   % ��ʱ��һ���mem.layer_inputs��mem.activations�Ѿ���ʼ����ϡ�
    if strcmp(config.forward_pass_scheme{2}, 'conv_v')
        conv2conv_mem(1);
    end
    for m = 2:layer_num
        % ֻҪ����conv�������conv_mem
        % ���Ҹ�����һ��ľ������ͽ����ٴε�mem
        % conv_v:conv2conv_mem;   conv_f����һ����out������conv2out_mem
        if strfind(config.forward_pass_scheme{m}, 'conv')
            conv_mem(m);
            if strcmp(config.forward_pass_scheme{m+1}, 'out') 
                conv2out_mem();
            elseif strcmp(config.forward_pass_scheme{m+1}, 'conv_v')
                conv2conv_mem(m);
            end
        end
    end
    
    % ������ˮ��
    config.pipeline_forward = {};
    config.pipeline_forward{1} = @input2conv;
    conv_layer_c = 1;
    for idx = 1:layer_num
        if strfind(config.forward_pass_scheme{idx}, 'conv')
            conv_layer_c = conv_layer_c + 1;
            % ǰ�򴫲�
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
                if strcmp(config.forward_pass_scheme{idx}, 'conv_f')   % �����ڶ���
                    config.pipeline_forward{length(config.pipeline_forward)+1} = @conv2out;
                    config.pipeline_forward{length(config.pipeline_forward)+1} = @out_forward;
                else
                    % conv_fֻ����conv��������
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

    config.EXPAND_DELTA_OUT = @expand_delta_out_nil;      % ����
    if strcmp(config.nonlinearity, 'relu')
        config.DERI_NONLINEARITY = @deri_relu;   
    end
    
    if strcmp(config.output_activation, 'nil')
        config.DERI_OUT_ACT = @deri_nonlinearity_nil; 
    end
    
    if strcmp(config.cost_function, 'L2 norm')
        config.DERI_COST_FUN = @deri_L2_norm;     
    end
    

    
    % �������򴫲���ˮ��
    config.pipeline_backprop = {};
    config.pipeline_backprop{1} = @out_backprop;
    % �����2��ʱҪ���������
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

%     % ���2��������������Ϊ�ڶ�����[1 1]�����Բ�δִ�д˳���
%     if strcmp(config.forward_pass_scheme{2}, 'conv_v') && config.kernel_size(2, 1) ~= 1 && config.kernel_size(2, 2) ~= 1
%         config.pipeline_backprop{length(config.pipeline_backprop)+1} = @convBconv_last;
%     end

    % �������һ��ķ�����ˮ��
    config.pipeline_backprop{length(config.pipeline_backprop)+1} = @convBinput;

    
    if strcmp(config.optimization, 'adagrad')        
        config.his_grad = {};
        config.fudge_factor = 1e-6;  
        if strcmp(config.forward_pass_scheme{1}, 'conv_v')
            config.UPDATE_WEIGHTS = @update_weights_adagrad;
            for m = 1:length(config.weights)  % ��6����ݶȽ��г�ʼ��Ϊ0
                config.his_grad{m} = config.NEW_MEM(zeros(size(config.weights{m})));
            end
        end
    end
end





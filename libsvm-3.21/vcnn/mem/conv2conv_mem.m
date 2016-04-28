function conv2conv_mem(layer_idx)
% 主要进行mem.conv2conv的初始化
    global config mem;
    conv_layer_idx = get_conv_layer_idx_from_layer_idx(layer_idx+1);  % conv_layer_idx = 2
    % valid_kernel_num是（feature_map_size{1}*batch_size),即mem.layer_inputs的第二维
    valid_kernel_num = (config.feature_map_sizes{layer_idx}(1)-config.kernel_size(conv_layer_idx, 1)+1)* ...
                       (config.feature_map_sizes{layer_idx}(2)-config.kernel_size(conv_layer_idx, 2)+1);
    % valid_kernel_num2 是feature_map_size{1}的底面积（除了厚度），即mem.activations的第二维
    valid_kernel_num2 = (config.feature_map_sizes{layer_idx}(1)-config.kernel_size(conv_layer_idx, 1)+1)* ...
                        (config.feature_map_sizes{layer_idx}(2)*2-config.kernel_size(conv_layer_idx, 2)+1);
    % 此时invalid_kernel_num为0   
    
    % 
    invalid_kernel_num = valid_kernel_num2 - 2 * valid_kernel_num;
    rm_idx = 1:config.kernel_size(conv_layer_idx, 1)*config.kernel_size(conv_layer_idx, 2)*config.feature_map_sizes{layer_idx}(3)*valid_kernel_num*config.batch_size;
    RM = reshape(rm_idx, config.kernel_size(conv_layer_idx, 1)*config.kernel_size(conv_layer_idx, 2)*config.feature_map_sizes{layer_idx}(3), ...
                                         valid_kernel_num*config.batch_size);
    RM_final = [];
    for m = 1:config.feature_map_sizes{layer_idx}(3)
        for n = 1:config.batch_size            
            section = padarray(RM((m-1)*config.kernel_size(conv_layer_idx, 1)*config.kernel_size(conv_layer_idx, 2)+1:m*config.kernel_size(conv_layer_idx, 1)*config.kernel_size(conv_layer_idx, 2), (n-1)*size(RM, 2)/config.batch_size+1:n*size(RM, 2)/config.batch_size), [0, invalid_kernel_num], 'replicate', 'post');
            RM_final = [RM_final; section(:)];
        end
    end
    
    mem.conv2conv{layer_idx+1} = {};    
    RM_final = RM_final(:);
    mem.conv2conv{layer_idx+1}{1} = RM_final(1:length(RM_final)-config.kernel_size(conv_layer_idx, 1)*config.kernel_size(conv_layer_idx, 2)*invalid_kernel_num);
    mem.conv2conv{layer_idx+1}{1} = config.NEW_MEM(mem.conv2conv{layer_idx+1}{1});
    
    mem.conv2conv{layer_idx+1}{2} = [];
    for m = 1:config.feature_map_sizes{layer_idx}(3)*config.batch_size-1
        mem.conv2conv{layer_idx+1}{2} = [mem.conv2conv{layer_idx+1}{2} m*valid_kernel_num+(m-1)*invalid_kernel_num+1:m*valid_kernel_num+(m-1)*invalid_kernel_num+invalid_kernel_num];
    end
    mem.conv2conv{layer_idx+1}{2} = config.NEW_MEM(mem.conv2conv{layer_idx+1}{2});
end



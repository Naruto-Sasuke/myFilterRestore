function conv_mem(layer_idx)
% 对conv层的mem的layer_inputs以及activations的初始化
    global mem;
    mem.layer_inputs{layer_idx} = 0;
    mem.activations{layer_idx} = 0;    
end

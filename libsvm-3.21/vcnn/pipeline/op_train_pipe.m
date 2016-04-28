function op_train_pipe(in, gt_out)
    global config mem;
    % config.misc主要是记录执行到某一层的信息。
    % forward pass
    config.misc.training = 1;
    mem.GT_output = gt_out; % 在反向传播中的cost_function中作为gt数据。在out_backprop中用到。
    config.pipeline_forward{1}(in); %  这里开始进行前向传播。pipeline_forward{1}是input2conv
    % 每一层进行前向传播。
    for m = 2:length(config.pipeline_forward)
        config.pipeline_forward{m}();
    end
    config.misc.current_layer = config.misc.current_layer - 1;
    % backprop
    for m = 1:length(config.pipeline_backprop)
        config.pipeline_backprop{m}();
    end
    config.misc.current_layer = 1;
end


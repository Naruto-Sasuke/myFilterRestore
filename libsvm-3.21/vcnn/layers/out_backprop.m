function out_backprop()
    global config mem;
    current_layer = config.misc.current_layer;
    % 求出第三层的梯度。即mem.deltas{3}
    mem.deltas{current_layer} = config.DERI_OUT_ACT(config.DERI_COST_FUN(mem.output, mem.GT_output));
    config.EXPAND_DELTA_OUT(); % 将delta{3}变成矩阵形式
    config.misc.current_layer = config.misc.current_layer - 1;
end

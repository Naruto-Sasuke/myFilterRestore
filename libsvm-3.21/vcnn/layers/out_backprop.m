function out_backprop()
    global config mem;
    current_layer = config.misc.current_layer;
    % �����������ݶȡ���mem.deltas{3}
    mem.deltas{current_layer} = config.DERI_OUT_ACT(config.DERI_COST_FUN(mem.output, mem.GT_output));
    config.EXPAND_DELTA_OUT(); % ��delta{3}��ɾ�����ʽ
    config.misc.current_layer = config.misc.current_layer - 1;
end

addpath applications/filterRestore/
addpath applications/filterRestore/utility/
addpath utils/
addpath cuda/
addpath mem/
addpath layers/
addpath layers_adapters/
addpath optimization/
addpath pipeline/
addpath data/
clearvars -global config;
clearvars -global mem;
clear;
global config mem;
configure();
init(0);

load('data/deepeaf/certainFilter/val/val_1');
perm = randperm(size(test_samples, 4));
test_samples = test_samples(:,:,:,perm);
test_labels = test_labels(:,:,:,perm);  
% 因为gen得到的数据都是single的，需要转换成gpuArray
test_samples = config.NEW_MEM(test_samples(:,:,:,1:200));
test_labels = config.NEW_MEM(test_labels(:,:,:,1:200));  % test去了前1/5的样本
% 为什么乘2？
test_samples = test_samples * 2;
test_labels = test_labels * 2;

count = 0;
cost_avg = 0;
epoc = 0;
points_seen = 0;
display_points = 500;
save_points = 5000;
fprintf('%s\n', datestr(now, 'dd-mm-yyyy HH:MM:SS FFF'));
for pass = 1:10      % 跑10次   
    for p = 1:100    % 每次100个
        load(strcat('data/deepeaf/certainFilter/train/patches_', num2str(p), '.mat'));        
        perm = randperm(1000);
        samples = samples(:,:,:,perm);
        labels = labels(:,:,:,perm);
        
        % train的样本是全部取
        train_imgs = config.NEW_MEM(samples);
        train_labels = config.NEW_MEM(labels); 
        train_imgs = train_imgs * 2;
        train_labels = train_labels * 2;
        
        for i = 1:size(train_labels, 4) / config.batch_size    % 对于每个mat(1000)，可共进行这么多次的训练(1000/10)        
            points_seen = points_seen + config.batch_size;
            in = train_imgs(:,:,:,(i-1)*config.batch_size+1:i*config.batch_size);
            out = train_labels(:,:,:,(i-1)*config.batch_size+1:i*config.batch_size);
            % 由于提取的训练数据out的底面积是64x64，而config.output_size是56x56.
            % 所以对out提取中间的一块。即是（5:60,5:60）
            out = out((size(in, 1) - config.output_size(1)) / 2 + 1:(size(in, 1) - config.output_size(1)) / 2 + config.output_size(1), ...
                      (size(in, 2) - config.output_size(2)) / 2 + 1:(size(in, 2) - config.output_size(2)) / 2 + config.output_size(2), :, :);
            
            % operate the training pipeline
            op_train_pipe(in, out);
            % update the weights
            config.UPDATE_WEIGHTS();
            
            if(cost_avg == 0)
                cost_avg = config.cost;
            else
                cost_avg = (cost_avg + config.cost) / 2;
            end

            % display point
            if(mod(points_seen, display_points) == 0)   
                count = count + 1;
                fprintf('%d ', count);
            end
            % save point
            if(mod(points_seen, save_points) == 0)
                fprintf('\n%s', datestr(now, 'dd-mm-yyyy HH:MM:SS FFF'));
                epoc = epoc + 1;
                test_cost = 0;
                 % test_samples = 200, batchsize = 10;  共20个。跑10pass，故共200个
                for t = 1:size(test_samples, 4) / config.batch_size
                    t_label = test_labels(:,:,:,(t-1)*config.batch_size+1:t*config.batch_size);
                    t_label = config.NEW_MEM(t_label((size(in, 1) - config.output_size(1)) / 2 + 1:(size(in, 1) - config.output_size(1)) / 2 + config.output_size(1), ...
                                            (size(in, 2) - config.output_size(2)) / 2 + 1:(size(in, 2) - config.output_size(2)) / 2 + config.output_size(2), :));
                    
                    op_test_pipe(test_samples(:,:,:,(t-1)*config.batch_size+1:t*config.batch_size), t_label);
                    test_out = gather(mem.output);
                    test_cost = test_cost + config.cost;
                end
                test_cost = test_cost / size(test_samples, 4);
                fprintf('\nepoc %d, training avg cost: %f, test avg cost: %f\n', epoc, cost_avg, test_cost);

                save_weights(strcat('applications/filterRestore/results/epoc', num2str(epoc), '.mat'));
                cost_avg = 0;
            end
        end
    end
end


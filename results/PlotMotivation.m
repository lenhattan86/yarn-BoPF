addpath('func');
common_settings;
figIdx = 0;

STEP_TIME = 1.0; 

fig_path = ['./figs/'];

is_printed = true;
numOfNodes = 40;
MAX_CPU = numOfNodes*32;
MAX_MEM = numOfNodes*64;
GB = 1024;
TB = 1024*1024;
extra='';

num_batch_queues = 1;
num_interactive_queue = 1;
num_queues = num_batch_queues + num_interactive_queue;

workload='BB';

enableSeparateLegend = true;

plots = [true false]; %DRF, DRF-W, Strict, SpeedFair

%%
if plots(1) 
  START_TIME = 1; END_TIME = 2600+START_TIME;  
  lengendStr = {'LQ','TQ'};
  
  queues = cell(1,num_queues);
  for i=1:num_interactive_queue
      queues{i} = ['bursty' int2str(i-1)];      
  end
  for j=1:num_batch_queues
      queues{num_interactive_queue+j} = ['batch' int2str(j-1)];
  end
  method = '';  
  
  is_switch_res = false; % switch CPU to MEM.

%   server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'DRF_mov'; method = 'DRF';
%  server='ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'Strict_mov_1';method = 'Strict';   
%   server='ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'SpeedFair_mov'; method = 'SpeedFair';

%   server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'DRF_mov'; method = 'DRF';
%  server='ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'Strict_mov';method = 'Strict';   
%   server='ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'SpeedFair_mov'; method = 'SpeedFair';

% server='ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'SpeedFair_mov_60_800'; method = 'SpeedFair';
  
%   server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'DRF_mov_80_600'; method = 'DRF';
%   server='ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'Strict_mov_80_600';method = 'Strict';
%     server='ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'SpeedFair_mov_80_600'; method = 'SpeedFair';     
%  server='ctl.yarn-drf.yarnrm-pg0.clemson.cloudlab.us'; subFolder = 'BPF_mov'; method = 'BPF'; 
%   server='ctl.yarn-drf.yarnrm-pg0.clemson.cloudlab.us'; subFolder = 'bug'; method = 'BPF';

%       server='ctl.yarn-drf.yarnrm-pg0.clemson.cloudlab.us'; subFolder = 'SpeedFair_mov_300_600'; method = 'SpeedFair'; is_switch_res = true;
%     server='ctl.yarn-drf.yarnrm-pg0.clemson.cloudlab.us'; subFolder = 'SpeedFair_mov_290_600'; method = 'SpeedFair'; is_switch_res = true;
        server='ctl.yarn-drf.yarnrm-pg0.clemson.cloudlab.us'; subFolder = 'SpeedFair_mov_280_600'; method = 'SpeedFair'; is_switch_res = true;

%   server=''; subFolder = 'Optimum'; method = 'Optimum';  stage1Period = 80; period = 600; submissionDelay = 20; queueUpPeriod = 200;

  
  subfolder = ['b' int2str(num_batch_queues) 'i1_' subFolder]; extra='';
  if num_batch_queues==0
      subFolder='';
      subfolder = ['b' int2str(num_batch_queues) 'i1'];
  end
 
  result_folder=['/home/tanle/projects/BPFImpl/results/' server '/' subfolder '/users/tanle/SWIM/scriptsTest/workGenLogs/'];
%   result_folder= ['/home/tanle/projects/BPFImpl/SWIM/scriptsTest/workGenLogs/'];
  logfolder = [result_folder];

  start_time_step = START_TIME/STEP_TIME;
  max_time_step = END_TIME/STEP_TIME;
  startIdx = start_time_step*num_queues+1;
  endIdx = max_time_step*num_queues;
  num_time_steps = max_time_step-start_time_step+1;
  linewidth= 2;
  barwidth = 1.0;
  timeInSeconds = (START_TIME:STEP_TIME:END_TIME) - START_TIME;


  extraStr = ['_' int2str(num_interactive_queue) '_' int2str(num_batch_queues)];

   if strcmp(method,'Optimum')
     flag = true;
     temp = (start_time_step:max_time_step);
     usedMEM = zeros(length(queues),length(temp));
     % batch jobs
     usedMEM(2,:) = MAX_MEM/GB;
     % stage 1 for first 2 jobs - bursty 
     jobNum1 = 2;
     for j = 1:jobNum1
       startTime = start_time_step + period*(j-1)+queueUpPeriod;
       usedMEM(1, startTime:stage1Period+startTime) = MAX_MEM/GB;
     end
     
     % stage 2 for 2 last jobs
     jobNum = 2;
%      stage1Period2 = period/2;
     stage1Period2 = 300;
     % stage 1 for first 2 jobs - bursty 
     jobNum2 = 2+jobNum1;
     for j = 3:jobNum2
       startTime = start_time_step + period*(j-1)+queueUpPeriod;
       usedMEM(1, startTime:stage1Period2+startTime) = MAX_MEM/GB;
     end
     for j = 1:2
       startTime = start_time_step + period*(j+1)+queueUpPeriod;
       stage2Res = period*MAX_MEM/2-stage1Period2*MAX_MEM;
       usedMEM(1, startTime+stage1Period2:period+startTime) = stage2Res/GB/(period-stage1Period2);
     end     
   else
    logFile = [ logfolder 'yarnUsedResources.csv'];
    [datetimes, queueNames, res1, res2, flag] = importRealResUsageLog(logFile); 
    res2=res2./TB;
      usedCPUs= zeros(length(queues),num_time_steps);
      usedMEM= zeros(length(queues),num_time_steps);
      queueIdxs = zeros(length(queues),num_time_steps);
      for i=1:length(queues)
        temp = find(strcmp(queueNames, ['root.' queues{i}]));
        len = min(length(temp),max_time_step); 
        endIdx= len-start_time_step+1;
        queueIdxs(i,1:endIdx)=temp(start_time_step:len);
        usedCPUs(i,1:endIdx) = res1(temp(start_time_step:len));
        usedMEM(i,1:endIdx) = res2(temp(start_time_step:len));
        if(is_switch_res)
          usedMEM(i,1:endIdx) = res1(temp(start_time_step:len))/1280*2.5;
        end
      end
   end
   
   if (flag)  
%       figure;
%       subplot(2,1,1); 
%       bar(timeInSeconds,usedCPUs',barwidth,'stacked','EdgeColor','none');
%       ylabel('CPUs');xlabel('seconds');
%       ylim([0 MAX_CPU]);
%       xlim([0 max(timeInSeconds)]);
%       legend(lengendStr,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');
%       title([method '- CPUs'],'fontsize',fontLegend);
%       colormap summer
      
      figure
%       subplot(2,1,2); 
      axes('linewidth',axisWidth,'box','on');      
      hold on;
      hBar = bar(timeInSeconds,usedMEM',barwidth,'stacked','EdgeColor','none');
      set(hBar,{'FaceColor'},colorb1i1); 
      
      ylabel('TB');xlabel('seconds');
      ylim([0 MAX_MEM/GB]);
      xlim([0 max(timeInSeconds)]);
      if ~enableSeparateLegend
        legend(lengendStr,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');
      end
      set(gca,'FontSize',fontSize)     
      
      set (gcf, 'Units', 'Inches', 'Position', figSizeOneColHaflRow, 'PaperUnits', 'inches', 'PaperPosition', figSizeOneColHaflRow);     
      if is_printed   
        figIdx=figIdx +1;
        fileNames{figIdx} = ['b' int2str(num_batch_queues) '_mov_' method '_' workload extra];        
        epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
        print ('-depsc', epsFile);
      end      
      
      %% create dummy graph with legends
      if enableSeparateLegend
        figure
        hBar = bar(timeInSeconds,usedMEM',barwidth,'stacked','EdgeColor','none');
        set(hBar,{'FaceColor'},colorb1i1);
        legend(lengendStr,'Location','southoutside','FontSize',fontLegend,'Orientation','horizontal');
        set(gca,'FontSize',fontSize);
        axis([20000,20001,20000,20001]) %move dummy points out of view
        axis off %hide axis  
        set(gca,'YColor','none');      
        set (gcf, 'Units', 'Inches', 'Position', legendSize, 'PaperUnits', 'inches', 'PaperPosition', legendSize);    
        
        if is_printed   
            figIdx=figIdx +1;
          fileNames{figIdx} = ['b' int2str(num_batch_queues) '_mov_legend'];        
          epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
          print ('-depsc', epsFile);
        end
      end
   end
end
%% total resource usage
%%
figSize = figSizeOneCol;
if plots(2)

    queues = cell(1,num_queues);
    for i=1:num_interactive_queue
        queues{i} = ['bursty' int2str(i-1)];
    end
    for j=1:num_batch_queues
        queues{num_interactive_queue+j} = ['batch' int2str(j-1)];
    end    
  
    beginTimeIdx = 1450;
    endTimeIdx = 2050;
    subfolder = 'users/tanle/SWIM/scriptsTest/workGenLogs/'; 
    csvFile = 'yarnUsedResources.csv';

    file = [subfolder csvFile];
    
    scaleUpFactorIdx = 1;
    
    drf_yarn_files = {
                    ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_DRF_mov_80_600/' file]                 
                  };

    strict_yarn_files = {
                ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_Strict_mov_80_600/' file]; % yarn-drf
              };
            
    speedFair_yarn_files = {
                ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_SpeedFair_mov_80_600/' file]; % yarn-drf
              }; 
            
    [ drf_avgRes1, drf_avgRes2, flag] = computeResourceUsage( drf_yarn_files{scaleUpFactorIdx}, queues, beginTimeIdx,  endTimeIdx);
    [ speedfair_avgRes1, speedfair_avgRes2, flag] = computeResourceUsage( speedFair_yarn_files{scaleUpFactorIdx}, queues, beginTimeIdx,  endTimeIdx);
    [strict_avgRes1, strict_avgRes2, flag] = computeResourceUsage( strict_yarn_files{scaleUpFactorIdx}, queues, beginTimeIdx,  endTimeIdx);    

  
  burstyIdxs = [1];
  batchIdxs = [2:2];
  drf_bursty = sum(drf_avgRes1( burstyIdxs));
  drf_batch = sum(drf_avgRes1( batchIdxs));
  speedFair_bursty = sum(speedfair_avgRes1( burstyIdxs));
  speedFair_batch = sum(speedfair_avgRes1( batchIdxs));
  strict_bursty = sum(strict_avgRes1( burstyIdxs));
  strict_batch = sum(strict_avgRes1( batchIdxs));
  
  avgRes1 = [drf_bursty, drf_batch, MAX_CPU - (drf_bursty+drf_batch) ; ...
    speedFair_bursty, speedFair_batch, MAX_CPU - (speedFair_bursty+speedFair_batch) ;...
    strict_bursty, strict_batch, MAX_CPU - (strict_bursty+strict_batch) ;
    ];
  
  drf_bursty = sum(drf_avgRes2( burstyIdxs));
  drf_batch = sum(drf_avgRes2( batchIdxs));
  speedFair_bursty = sum(speedfair_avgRes2(burstyIdxs));
  speedFair_batch = sum(speedfair_avgRes2(batchIdxs));
  strict_bursty = sum(strict_avgRes2(burstyIdxs));
  strict_batch = sum(strict_avgRes2(batchIdxs));
  
  avgRes2= [drf_bursty, drf_batch, MAX_MEM*GB - (drf_bursty+drf_batch) ; ...
    speedFair_bursty, speedFair_batch, MAX_MEM*GB - (speedFair_bursty+speedFair_batch) ;...
    strict_bursty, strict_batch, MAX_MEM*GB - (strict_bursty+strict_batch) ;
    ];
  
  colorQueueType = {colorBursty; colorBatch; colorWasted};
  stackLabels = {strLQ,strTQ,'Unallocated'};
  groupLabels = {strDRF, strProposed, strStrict};  
  resGroupBars = avgRes2/(MAX_MEM*GB);
  hBar = bar(1:3,resGroupBars, 0.5, 'stacked');
  set(hBar,{'FaceColor'}, colorQueueType);
%   set(hBar,{'FaceColor'}, colorQueueType);
%   h = plotBarStackGroups(resGroupBars, colorQueueType);  
  ylim([0 1]);
  legend(stackLabels,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');  
  set(gca,'XTickLabel', groupLabels, 'FontSize', fontAxis);   
  
  set (gcf, 'Units', 'Inches', 'Position', figSize, 'PaperUnits', 'inches', 'PaperPosition', figSize);     
  if is_printed   
    figIdx=figIdx +1;
    fileNames{figIdx} = ['b' int2str(num_batch_queues) '_avg_res_' workload extra];        
    epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
    print ('-depsc', epsFile);
  end   
  
end
fileNames
%%
return;
%%

for i=1:length(fileNames)
    fileName = fileNames{i};
    epsFile = [ LOCAL_FIG fileName '.eps'];
    pdfFile = [ fig_path fileName  '.pdf']    
    cmd = sprintf(PS_CMD_FORMAT, epsFile, pdfFile);
    status = system(cmd);
end
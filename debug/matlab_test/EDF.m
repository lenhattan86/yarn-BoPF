
% job profile -[ID, arrival_time, demand,total_demand, deadlines]
% available resource  - avail_res(t) is the total available resource at
% time (t-1) to t.
% algorithm: vanilla earliest deadline first


function [res_mat, job_finished, res_avail] = EDF(job_profile, avail_res,end_time)

[job_num,~] = size(job_profile);

res_mat = zeros(job_num,end_time);
job_finished  = zeros(job_num,2);
sorted_job_profile = sortrows(job_profile,5);   % sort based on deadlines
for i = 1: end_time
    for j = 1:job_num
        if sorted_job_profile(j,2) <= (i-1) && sorted_job_profile(j,3) <= avail_res(i) && sorted_job_profile(j,4)>0
            % schedule job j
            sorted_job_profile(j,4) = sorted_job_profile(j,4) - sorted_job_profile(j,3);
            avail_res(i) = avail_res(i)- sorted_job_profile(j,3);
            res_mat(sorted_job_profile(j,1),i) = sorted_job_profile(j,3);
            if sorted_job_profile(j,4) == 0 && i <= sorted_job_profile(j,5)
                job_finished(sorted_job_profile(j,1),1) = 1;
                job_finished(sorted_job_profile(j,1),2) = i;
            end
        end
    end
end

res_avail = avail_res;
end
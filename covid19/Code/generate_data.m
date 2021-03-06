
load('../Data/M.mat') %M(l,l,t)
load('../Data/pop.mat') % pop(l)
load('../Data/incidence.mat') % O(t,l)
obs_truth=incidence'; % obs(l,t)
fig_folder = '~/tmp/Figures';


input_data.M = M;
input_data.pop = pop;

model.params = set_params;
model.add_noise = false;
model.add_delay = false;
model.num_ens = 1; % single sample
model.num_integration_steps = 1;
model.rounding = true;


pop0 = pop;
z0 = initialize_state_deterministic(pop0, M, model.rounding);
[beta, mu, theta, Z, alpha, D] = unpack_params(model.params);

T = 5;

%{
ztrace = cell(1,T+1);
delta_trace = cell(1,T+1);
pop_trace = cell(1,T+1);
ztrace{1} = z0;
pop_trace{1} = pop0;
delta_trace{1} = zeros(num_states,1);
rounding = true;
for t=2:T+1
    [ztrace{t}, delta_trace{t}] = deterministic_dynamics(...
        ztrace{t-1}, model.params, pop_trace{t-1}, M(:,:,t-1));
    pop_trace{t} = update_pop(pop_trace{t-1}, M(:,:,t-1), theta, pop0, rounding);
    %pop_trace{t} = pop_trace{t-1};
end
%}

ztrace = cell(1,T);
delta_trace = cell(1,T);
pop_trace = cell(1,T);
rounding = true;
for t=1:T
    if t==1
        [ztrace{t}, delta_trace{t}] = deterministic_dynamics(...
            z0, model.params, pop0, M(:,:,1), model.rounding);
        pop_trace{t} = update_pop(pop0, M(:,:,t), theta, pop0);
    else
        [ztrace{t}, delta_trace{t}] = deterministic_dynamics(...
            ztrace{t-1}, model.params, pop_trace{t-1}, M(:,:,t-1), model.rounding);
         pop_trace{t} = update_pop(pop_trace{t-1}, M(:,:,t-1), theta, pop0);
    end

end

thresh = 1;
for t=T:T
    plot_nonzero_states(ztrace{t}, t, thresh); suptitle('z')
    plot_nonzero_states(delta_trace{t}, t, thresh); suptitle('delta')
end



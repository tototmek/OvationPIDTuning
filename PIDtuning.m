MAX_ITER = 200;
najm_kw = ones(MAX_ITER, 1) * 2e5;

p=classPID(2, 25, 0, 1, 1, 100, -100, 1, 1, 0);
lag = classLAG(1);

repeat = true;
j = 1;
disp ("Etap 1 - P")
while repeat
    j = j+1;
    old_params = [p.K, p.Ti, p.Kd, p.Td];
    p.reTune(p.K*1.01, p.Ti, p.Kd, p.Td);
    %eksperyment
    sim_time = 7500;
    stpt = 20;
    pv=0;
    u=zeros(sim_time + 21, 1);
    out = zeros(sim_time, 1);
    najm_kw(j) = 0;
    for i=1:1:sim_time
        if i == 3250
            stpt = 10;
        end
        u(i+21) = p.calc(pv,stpt);
        pv = 0.37 * lag.calc(120, u(i));
        out(i) = pv;
        najm_kw(j) = najm_kw(j) + (stpt - pv).^2;
    end
    if najm_kw(j) >= najm_kw(j-1)
        repeat = false;
    end
end
repeat = true;
disp ("Etap 2 - I")
while repeat
    j = j+1;
    old_params = [p.K, p.Ti, p.Kd, p.Td];
    p.reTune(p.K, p.Ti*0.99, p.Kd, p.Td);
    %eksperyment
    sim_time = 7500;
    stpt = 20;
    pv=0;
    u=zeros(sim_time + 21, 1);
    out = zeros(sim_time, 1);
    najm_kw(j) = 0;
    for i=1:1:sim_time
        if i == 3250
            stpt = 10;
        end
        u(i+21) = p.calc(pv,stpt);
        pv = 0.37 * lag.calc(120, u(i));
        out(i) = pv;
        najm_kw(j) = najm_kw(j) + (stpt - pv).^2;
    end
    
    if najm_kw(j) >= najm_kw(j-1)
        repeat = false;
    end
end

disp(p)
disp(old_params)
disp(najm_kw(j-1))
plot(najm_kw(1:1:j))
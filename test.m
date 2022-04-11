%Ten przyk³ad pokazuje jak u¿yæ klasê regulatora PID
%Regulator PID jest realizowany równolegle jako cz³ony
% Proporcja: K
% Ca³ka: 1/Ti s
% Ró¿niczka: Kd - Kd/(Td * s + 1) - po skoku err sterowanie ustawiane jest na wartoœæ Kd i zmniejszane po LAGu
clear all;

%classPID(K, Ti, Kd, Td, Tp, Hlim, Llim, Dir, AutoMan, ManVal) 
%DIR: 1 - direct (SP-PV), 0 - indirect (PV-SP)
% AutoMan = 0 regulator na wyjœciu podaje wartoœæ sterowania rêcznego ManVal
% AutoMan = 1 regulator na wyjœciu podaje wartoœæ wyliczon¹ z prawa regulacji
%Przyklad: deklaracja regulatora D
p=classPID(3.7435, 18.1245, 0, 1, 1, 100, -100, 1, 1, 0)
lag = classLAG(1)
%PID
%reTune(obj, K, Ti, Kd, Td)
% funkcja umo¿liwia zmianê nastaw regulatora
%p.reTune(1, 30, 0.5, 30)
sim_time = 7500;
stpt = 20;
pv=0;
u=zeros(sim_time + 21, 1);
out = zeros(sim_time, 1);
najm_kw = 0;
for i=1:1:sim_time
  if i == 3250
    stpt = 10;
  end
  %metoda wyliczaj¹ca prawo PID w oparciu o PV i STPT
  u(i+21) = p.calc(pv,stpt);
  pv = 0.37 * lag.calc(120, u(i));
  out(i) = pv;
  najm_kw = najm_kw + (stpt - pv).^2;
  %tutaj nale¿y symulowaæ obiekt
  %wyliczenie wyjscia obiektu na nastepny krok wykorzystujac u
end
najm_kw
plot(out);





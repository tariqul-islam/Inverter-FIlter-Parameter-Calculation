function rd_cd_lcl_bode(L1,L2,Cf,Cd,Rd)
% rd_cd_lcl_bode(L1,L2,Cf,Cd,Rd)
%
% Plots the Bode Plot of Rd-Cd Clamped
% LCL passive filter
%
    num = [Cd*Rd 1];
    den = [L1*L2*Cf*Cd*Rd L1*L2*(Cf+Cd) (L1+L2)*Cd*Rd (L1+L2) 0];
    
    sys = tf(num,den);
    
    bodeplot(sys);
end

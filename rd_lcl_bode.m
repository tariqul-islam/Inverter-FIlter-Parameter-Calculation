
function rd_lcl_bode(L1,L2,Cf,Rd)
% rd_cd_lcl_bode(L1,L2,Cf,Cd,Rd)
%
% Plots the Bode Plot of Rf Damped
% LCL passive filter
% give Rd=0 for LCL Filter without damping
    num = [Cf*Rd 1];
    den = [L1*L2*Cf (L1+L2)*Cf*Rd (L1+L2) 0];
    
    sys = tf(num,den);
    
    bodeplot(sys);
    set(gca,'xcolor','k') 
    set(gca,'ycolor','k')
end
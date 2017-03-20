clc;
clear;
close all;

%%
%Inputs

%Switching Frequency in KHz
fs = 8; %KHz
fs = fs*1000;
ws = 2*pi*fs;

%output frequency
fo = 50; %Hz
wo = 2*pi*fo;

%DC Voltage input at Inverter
Vdc = 380; %Volt

%RMS AC voltage
%
Vac = 230; %Volt

%Rated Output Power
Prated = 500; %Watt

%required current ripple
% a value between 0 and 1
% Old/Rd damped LCL papers use ~10%
%newer/Rd-Cd dampled LCL or LLCL papers use ~30%
%LLCL paper recommended 15% to 40%
%higher means more ripple.
%Note: Old papers use 5-8KHz switching freq
%LLCL one uses 20KHz
%I couldn't find any particular liturature that
%focuses on this particular area
ripple = 0.1;

%Harmonic Attenuation
%Select desired value
%most papers select 20%
ka = 0.2;

%Max Power factor variation seen by the grid
react = 0.05;

%%
%Calculations
%Some recommended values

%Reference Current
Iref = Prated/Vac;

%Base Impedance
Zb = (Vac)^2 / Prated;

%Bse Capacitance
Cb = 1/(wo*Zb);

%Maximum Capacitance
Cm = react * Cb;
Cf = Cm;
fprintf('Selected Cf = %f micro Farad\n', Cf*10^6);
fprintf('during design select a value lower than Cf to limit PF change further\n');
%Slecet a value lower than Cm to limit PF change further


%Inverter Side Inductor
L1 = Vdc / (6 * fs * ripple * Iref); %H
fprintf('Selected L1 = %f mili Henry\n', L1*10^3)

%Grid Side Inverter
L2_calc = @(x) ( ( sqrt( 1/ka^2 ) + 1 ) / (x * ws^2 ) );

L2 = L2_calc(Cf);
fprintf('Selected L2 = %f mili Henry\n', L2*10^3)
fprintf('however, some papers suggest that L2 = L1\n\n')
%however, some papers suggest that L2 = L1

%%
%Select Filter Type and Design

in = 0;
while in<1 || in>2
    fprintf('Select the filter type you want to simulate:\n')
    fprintf('1. Rd damped LCL filter\n')
    fprintf('2. Rd-Cd damped LCL Filter\n')
    in = input('Input 1 or 2 to simulate one of the filters: ');
    
    if isempty(in)
        in=0;
        fprintf('\n\nRetry!!!\n\n')
    end
end

if in==1
    %change value of Cf
    fprintf('\n\nPreviously Cm = %f uF\n', Cm * 10^6);
    fprintf('It is advised that selected Cf is lower than this value.\n');
    in = input('Enter Cf in micro Farad, press enter to keep unchanged: ');
    fprintf('\n\n')
    if ~isempty(in)
        Cf = in * 10^-6;
    end
    
    %change value of L2
    L2 = L2_calc(Cf);
    
    %calculte resonant freq
    wres = sqrt( ( L1 + L2 ) / (L1 * L2 * Cf ) );
    fres = wres / ( 2*pi );
    fprintf('Resonant Frequency: %f KHz\n', fres/1000)
    if fres<10*fo || fres>fs/2
        warning('Resonant Freq doesnot match! Recalculation changing parameters is advised.') 
    end
    
    Rd = 1 / ( 3 * wres * Cf );
    
    %Selected values
    fprintf('\nSelected Parameters:\n')
    fprintf('Cf = %f uF\n', Cf * 10^6)
    fprintf('L1 = %f mH\n', L1 * 10^3)
    fprintf('L2 = %f mH\n', L2 * 10^3)
    fprintf('Rd = %f ohm\n', Rd)
    
    rd_lcl_bode(L1,L2,Cf,Rd)
    title('Bode Plot of Rd Damped LCL Filter')

elseif in==2    
    %change value of Cf
    fprintf('\n\nPreviously Cm = %f uF\n', Cm * 10^6);
    fprintf('It is advised that selected Cf+Cd<=Cm.\nCf=Cd is considered a good trade off\n');
    in = input('Enter Cf in micro Farad, Press enter to select Cm/2: ');
    fprintf('\n\n')
    if ~isempty(in)
        Cf = in * 10^-6;
    else
        Cf = Cm / 2;
    end
    
    %Select Cd
    in = input('Enter Cd in micro farad, Press enter to select Cm/2: ');
    fprintf('\n\n');
    if ~isempty(in)
        Cd = in * 10^-6;
    else
        Cd = Cm / 2;
    end
    
    %change value of L2
    L2 = L2_calc( Cf + Cd );
    
    %select Rd
    alpha = Cd/Cf;
    wres = sqrt( ( L1 + L2 ) / (L1 * L2 * Cf ) );
    factor = sqrt( L1 * L2 / ( ( L1 + L2 ) * Cf ));
    Rd_min = sqrt( alpha + 1 ) / alpha * factor;
    Rd_max = ( alpha + 1 ) / alpha * factor;
    
    %Rd_min = sqrt( alpha + 1 ) / alpha * wres;
    %Rd_max = ( alpha + 1 ) / alpha * wres;
    
    fprintf('\n\nvalue of Rd is advised to be between %f and %f\n', Rd_min, Rd_max);
    in = input('Select a value for Rd, press enter to select average: ');
    
    if ~isempty(in)
        Rd = in;
    else
        Rd = ( Rd_min + Rd_max ) / 2;
    end
    
    %Selected Values
    fprintf('\nSelected Parameters:\n')
    fprintf('Cf = %f uF\n', Cf * 10^6)
    fprintf('L1 = %f mH\n', L1 * 10^3)
    fprintf('L2 = %f mH\n', L2 * 10^3)
    fprintf('Cd = %f uF\n', Cd * 10^6)
    fprintf('Rd = %f ohm\n', Rd)
    
    figure,rd_cd_lcl_bode(L1,L2,Cf,Cd,Rd);
    title('Bode Plot of Rd-Cd Damped LCL Filter')
end
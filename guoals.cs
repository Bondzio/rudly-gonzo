F = 48;
F.InputName = 'rSwitchOutputName';     F.OutputName = 'rf';      F.Name = 'F';
% Define C
C = 16;
C.InputName = 'e';     C.OutputName = 'uc';      C.Name = 'C';
% Define G
G = 64;
G.InputName = 'u';     G.OutputName = 'yg';      G.Name = 'G';
% Define H
H = 128;
H.InputName = 'y';     H.OutputName = 'yh';      H.Name = 'H';

% Get system IO sizes
[nOutputF, nInputF] = iosize(F);
[nOutputC, ~] = iosize(C);
[nOutputG, ~] = iosize(G);
[nOutputH, ~] = iosize(H);

% Create the summing junctions
eSum = sumblk('eSwitchInputName = -ym + rf',nOutputF); % Sum at e
uSum = sumblk('uSwitchInputName = uc + du',nOutputC); % Sum at u
ySum = sumblk('ySwitchInputName = yg + dy',nOutputG); % Sum at y
ymSum = sumblk('ymSwitchInputName = yh + n',nOutputH); % Sum at ym

% Create the Analysis Points
rSwitch = AnalysisPoint('r',nInputF); % Analysis Point at r
rSwitch.InputName = 'r';     rSwitch.OutputName = 'rSwitchOutputName';
eSwitch = AnalysisPoint('e',nOutputF); % Analysis Point at e
eSwitch.InputName = 'eSwitchInputName';     eSwitch.OutputName = 'e';
uSwitch = AnalysisPoint('u',nOutputC); % Analysis Point at u
uSwitch.InputName = 'uSwitchInputName';     uSwitch.OutputName = 'u';
ySwitch = AnalysisPoint('y',nOutputF); % Analysis Point at y
ySwitch.InputName = 'ySwitchInputName';     ySwitch.OutputName = 'y';
ymSwitch = AnalysisPoint('ym',nOutputH); % Analysis Point at ym
ymSwitch.InputName = 'ymSwitchInputName';     ymSwitch.OutputName = 'ym';

% Construct the closed loop system
Inputs = {'r';'du';'dy';'n'};
Outputs = {'y';'e';'u';'ym'};
CL0 = connect(C,F,G,H,eSum,uSum,ySum,ymSum,rSwitch,eSwitch,uSwitch,ySwitch,ymSwitch,Inputs,Outputs);
Unable to perform assignment because dot indexing is not supported for variables of this type.

Error in Untitledgoul (line 4)
F.InputName = 'rSwitchOutputName';     F.OutputName = 'rf';      F.Name = 'F';
Create tuning goal to limit LQR cost in response to white noise inputs

Inputs and outputs

Inputs = {'n'; ...
          'r'; ...
          'du'};
Outputs = {'e'; ...
           'ym'};
% Tuning goal specifications
NoiseCovariance = 1; % Noise covariance matrix of the noise inputs
PerformanceWeight = 1; % Weight for the performance signals
% Create tuning goal for LQG
LQGGoal1 = TuningGoal.LQG(Inputs,Outputs,NoiseCovariance,PerformanceWeight);
% Open these signals
LQGGoal1.Openings = {'u'; ...
                     'ym'};
LQGGoal1.Name = 'LQGGoal1'; % Tuning goal name
Create option set for systune command

Options = systuneOptions();
Options.Display = 'off'; % Tuning display level ('final', 'sub', 'iter', 'off')
Options.UseParallel = true; % Parallel processing flag
Set soft and hard goals

SoftGoals = [];
HardGoals = [ LQGGoal1 ];
Tune the parameters with soft and hard goals

[CL1,fSoft,gHard,Info] = systune(CL0,SoftGoals,HardGoals,Options);
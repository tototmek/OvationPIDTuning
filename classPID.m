%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Praca magisterska
%
%       autor:	Mateusz Ciok
%       promotor:	dr inz. Sebastian Plamowski
%
%       Wydzial Elektroniki i Technik Informacyjnych
%       Politechnika Warszawska,
%
%       2017
%
% mateusz@ciok.waw.pl
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef classPID < handle
    % classPID - PID regulator implementation
    %
    % #####################################################################
    % Private internal
    properties(GetAccess = 'public', SetAccess = 'private')
        % Tuning parameters
        K = 1;          % Gain
        Ti = 30;        % Integration time
        Kd = 0;         % Derivation gain
        Td = 0;         % Derivation time
        Tp = 1;         % Sample time
        Dir = 0;        % 1 - direct (SP-PV), 0 - indirect (PV-SP)
        Hlim = 0;       % high limit
        Llim = 0;       % low limit
        AutoMan = 0;    % MAN when AutoMan equals to 0
        ManVal = 0;     % output in MAN mode;
    end
    
    properties(GetAccess = 'public', SetAccess = 'private')
        coeffI = 0;         %coefficients
        coeffD = 0;
        oldIOut = 0;        % internal state
        oldDOut = 0;          
        err = zeros(1,2);   % err at "k" and "k-1" moment
    end
    
    % #####################################################################
    % PUBLIC atributes
    properties(GetAccess = 'public', SetAccess = 'public')
        PV = 0;     %Process Variable
        SP = 0;     %Setpoint
        out = 0;    %PID output

    end
    
    % PUBLIC methods ######################################################
    methods(Access = 'public')
        % constructor
        function obj = classPID(K, Ti, Kd, Td, Tp, Hlim, Llim, Dir, AutoMan, ManVal) 
            % set internal parameters
            obj.Tp = Tp;
            obj.Hlim = Hlim;
            obj.Llim = Llim;
            obj.Dir = Dir;  %1 - direct (SP-PV), 0 - indirect (PV-SP)
            obj.AutoMan = AutoMan;
            obj.ManVal = ManVal;
            
            obj.reTune(K, Ti, Kd, Td);
        end
        
        % #################################################################
        % calc PID: obj.calc(PV) or obj.calc(PV, SP)
        function output = calc(obj, varargin)
           switch nargin
               case 2 % one argument
                  obj.PV = varargin{1};
               case 3 % two arguments
                   obj.PV = varargin{1};
                   obj.SP = varargin{2};
               otherwise
                   error('error: wrong number of parameters');
           end

           % err calculation
           obj.err(2) = obj.err(1);
           if obj.Dir   % direct
               obj.err(1) = obj.SP - obj.PV;
           else         % indirect
               obj.err(1) = obj.PV - obj.SP;
           end
                   
           %PID math
           pTerm = obj.K * obj.err(1);
           iTerm = obj.coeffI * obj.err(1) + obj.coeffI * obj.err(2) + obj.oldIOut;
           %dTerm = obj.coeffD * obj.oldDOut + obj.Kd/(2 * obj.Td + obj.Tp) * (obj.err(1) - obj.err(2));
           dTerm = obj.coeffD * obj.oldDOut + obj.Kd * (obj.err(1) - obj.err(2));
           obj.out = pTerm + iTerm + dTerm;
        
           obj.oldIOut = iTerm;
           obj.oldDOut = dTerm;
           
           %MAN
           if obj.AutoMan == 0
               obj.out = obj.ManVal;
               obj.oldIOut = (obj.out - (pTerm + dTerm));
           end
           
           % limits
           if obj.out > obj.Hlim
               obj.out = obj.Hlim;
               obj.oldIOut = (obj.out - (pTerm + dTerm));
           end
           if obj.out < obj.Llim
               obj.out = obj.Llim;
               obj.oldIOut = (obj.out - (pTerm + dTerm));
           end
           
           if obj.AutoMan == 1
               obj.ManVal = obj.out;
           end
           % return value
           output = obj.out;
        end
        
        % PID tuning ######################################################
        function  reTune(obj, K, Ti, Kd, Td)
            obj.K = K;
            obj.Ti = Ti;
            obj.Kd = Kd;
            
            if Td < obj.Tp/2
                Td = obj.Tp/2;
            end
            obj.Td = Td;
            obj.Tp = obj.Tp;
            
           
            % coefficients recalculation
            if Ti > 0
                obj.coeffI = obj.Tp/(2*Ti);
            else
                obj.coeffI = 0;
            end
          
            obj.coeffD = (2*Td - obj.Tp)/(2*Td + obj.Tp);
        end

        % AutoMan #########################################################
        function  SetAutoMan(obj, AutoMan, ManVal)
            obj.AutoMan = AutoMan;
            obj.ManVal = ManVal;
        end
        
		% PID internal state oldIOut update ###############################
        function  stateUpdate(obj, Iout)
            obj.oldIOut = Iout;
        end
    end
end


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

classdef classLAG < handle
    
    properties(GetAccess = 'public', SetAccess = 'public')
        T;          % denominator time constant
        SHEET_TIME; % period of control sheet ?
        X;          % IN value from last cycle  
        
        Prev_X;     % previous input from last cycle
        Prev_LAG;   % previous output
    end
    
    properties(GetAccess = 'private', SetAccess = 'private')
        
    end
    
    methods
        % constructor
        function obj = classLAG(SHEET_TIME)
            obj.SHEET_TIME = SHEET_TIME;
            obj.Prev_X = 0;
            obj.Prev_LAG = 0;
        end
        
        % calculate output
        function LAG = calc(obj,T,X)
           obj.T = T;
           obj.X = X;
           
           if (T == 0)
                LAG = X;
                return;
           end
           if (T < obj.SHEET_TIME)
               T = obj.SHEET_TIME;
               obj.T = T;
           end
           
           K1 = obj.SHEET_TIME/(2*T + obj.SHEET_TIME);
           K2 = (2*T - obj.SHEET_TIME)/(2*T + obj.SHEET_TIME);
           
           % output
           LAG = K1*(X + obj.Prev_X) + K2*obj.Prev_LAG;
           
           % previous input and output
           obj.Prev_X = X;
           obj.Prev_LAG = LAG;
           
        end
    end
    
end


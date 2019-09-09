function [value,validvalue, errmsg, errid, validfield] = checkfield(field, value, validStrings)
%

%CHECKFIELD Check validity of optimization options
%

%   [VALIDVALUE, ERRMSG, ERRID, VALIDFIELD] =
%   OPTIMOPTIONCHECKFIELD('field',V) checks the contents of the specified
%   value V to be valid for the field 'field'.
%
%   [VALIDVALUE, ERRMSG, ERRID, VALIDFIELD] =
%   OPTIMOPTIONCHECKFIELD('field',V, VALIDSTRINGS) checks the contents of
%   the specified value V to be valid for the field 'field'. In the case
%   where V can be a string, VALIDSTRINGS contains the possible strings
%   that V can take. VALIDSTRINGS can be a string or a cell array.

%   Copyright 2012-2018 The MathWorks, Inc.

% Prepare any values that are specified as strings or character vectors. In
% particular, deblank the string and convert it to lower case except for
% function handles.
value = prepareStringValue(field, value);

% To check strings, checkfield specifies the known string in lower case.
% Convert validStrings to lower case if specified.
if nargin > 2
    validStrings = lower(validStrings);
end

% Some fields are checked in optimset/checkfield: Display, MaxFunEvals, MaxIter,
% OutputFcn, TolFun, TolX. Some are checked in both (e.g., MaxFunEvals).
validfield = true;
switch field
    % One of the following:
    % - Empty
    % - Function name
    % - Function handle or cell array
    % - Cell array of plot functions 
    case {'PlotFcns','PlotFcn','CreationFcn', 'FitnessScalingFcn', ...
            'SelectionFcn','CrossoverFcn','MutationFcn', ...
            'DistanceMeasureFcn', 'SearchFcn', 'SearchMethod', ...
            'AcceptanceFcn', 'AnnealingFcn', 'TemperatureFcn'}
        if isempty(value)
            validvalue = true;
            errmsg = '';
            errid = '';
        elseif ischar(value) && ~isempty(validStrings)
            % Check that the value is one of the shipping function names
            [validvalue, errmsg, errid] = stringsType(field,value,validStrings);
        else
            [validvalue, errmsg, errid] = functionOrCellArray(field,value);
            if ~isempty(validStrings) && isempty(errid) && iscell(value) && ...
                    any(strcmp(field, {'PlotFcns', 'PlotFcn'}))
                % Check that any strings in the PlotFcn cell array are one
                % of the shipping functions only.
                for i = 1:numel(value)
                    if ischar(value{i}) && isempty(errid)
                        [validvalue, errmsg, errid] = ...
                            stringsType(field,value{i},validStrings);
                    end
                end
            end
        end
        % Function or empty
    case {'OutputFcn','OutputFcns'}
        if isempty(value)
            validvalue = true;
            errmsg = '';
            errid = '';
        else
            [validvalue, errmsg, errid] = functionOrCellArray(field,value);
        end
    case {'Display','RandomSampler'}
        [validvalue, errmsg, errid] = stringsType(field,value,validStrings);
    case {'CheckGradients', 'HonorBounds', 'SpecifyConstraintGradient', ...
          'SpecifyObjectiveGradient', 'UseVectorized', 'UseCompletePoll', ...
          'UseCompleteSearch', 'AccelerateMesh', 'ScaleMesh', 'EnablePresolve',...
          'UseCache'}
        [validvalue, errmsg, errid] = logicalType(field,value);
    case {'RelLineSrchBnd'}
        if isempty(value)
            validvalue = true;
            errmsg = '';
            errid = '';
        else
            [validvalue, errmsg, errid] = nonNegReal(field,value);
        end
    case {'TolFun','TolX','TolCon','TolPCG','ActiveConstrTol',...
          'DiffMaxChange','DiffMinChange','MaxTime','TimeLimit', ...
          'TolProjCGAbs', 'TolProjCG','TolGradCon','TolConSQP',...
          'TolGapAbs', 'InitDamping', 'ConstraintTolerance','EliteCount', ...
          'FunctionTolerance', 'OptimalityTolerance', 'StepTolerance', ...
          'AbsoluteGapTolerance', 'MeshTolerance','TolFunValue', 'CacheTol', ...
          'CacheSize', 'MaxMeshSize', 'TolBind', 'TolMesh', ...
          'ActiveConstraintTolerance','ParetoSetChangeTolerance','MinSampleDistance'}
        % non-negative real scalar
        [validvalue, errmsg, errid] = nonNegReal(field,value);
    case {'TolFunLP', 'LPOptimalityTolerance'}
        % real scalar in the range [1e-10, 1e-1]
        [validvalue, errmsg, errid] = boundedReal(field,value,[1e-10, 1e-1]);
    case {'TolGapRel','RelObjThreshold','MinFractionNeighbors','MinNeighborsFraction', ...
          'ParetoFraction','CrossoverFraction','RelativeGapTolerance', ...
          'ObjectiveImprovementThreshold', 'MigrationFraction','MinPollFraction'}
        % real scalar in the range [0, 1]
        [validvalue, errmsg, errid] = boundedReal(field,value,[0,1]);
    case {'MeshContractionFactor', 'MeshContraction'}
        % real scalar > 1.0, < Inf
        [validvalue, errmsg, errid] = openRangeReal(field,value,[0.0, 1.0]);
    case {'MeshExpansionFactor', 'MeshExpansion'}
        % real scalar > 1.0, < Inf
        [validvalue, errmsg, errid] = openRangeReal(field,value,[1.0, Inf]);
    case {'TolInteger','IntegerTolerance'}
        % real scalar in the range [1e-6, 1e-3]
        [validvalue, errmsg, errid] = boundedReal(field,value,[1e-6, 1e-3]);
    case {'ObjectiveLimit','FitnessLimit'}
        [validvalue, errmsg, errid] = realLessThanPlusInf(field,value);
    case {'SwarmSize'}
        [validvalue, errmsg, errid] = boundedInteger(field, value, [2,realmax]);
    case {'LargeScale','DerivativeCheck','Diagnostics','GradConstr','GradObj',...
          'Jacobian','NoStopIfFlatInfeas','PhaseOneTotalScaling', ...
          'FunValCheck', 'Vectorized', 'MeshRotate', 'Cache', ...
          'CompletePoll', 'CompleteSearch', 'MeshAccelerator'}
        % off, on
        [validvalue, errmsg, errid] = stringsType(field,value,{'on';'off'});
    case {'PrecondBandWidth','MinAbsMax','GoalsExactAchieve', ...
          'RelLineSrchBndDuration', 'DisplayInterval', 'ReannealInterval', ...
          'RootLPMaxIter', 'RootLPMaxIterations', 'MaxFunEvals', 'MaxFunctionEvaluations', ...
          'MaxProjCGIter', 'MaxSQPIter', 'MaxPCGIter', 'MaxIter', ...
          'MaxIterations',  'EqualityGoalCount', 'Generations', 'MaxGenerations', ...
          'MaxStallGenerations', 'StallGenLimit', 'MigrationInterval', ...
          'PopulationSize', 'AbsoluteMaxObjectiveCount', 'HybridInterval', ...
          'FrontSize','Verbosity','MinSurrogatePoints'}
        % integer including inf
        [validvalue, errmsg, errid] = nonNegInteger(field,value);
    case {'StallIterLimit','MaxStallIterations'}
        % non-negative integer excluding inf
        [validvalue, errmsg, errid] = boundedInteger(field,value,[0,realmax]);
    case {'InitialSwarm','InitialSwarmMatrix','InitialPopulationMatrix', ...
          'InitialPopulation', 'InitialScoresMatrix', 'InitialScores'}
        % matrix
        [validvalue, errmsg, errid] = twoDimensionalMatrixType(field,value);
    case {'JacobPattern', 'HessPattern', 'InitialTemperature'}
        % matrix or default string
        [validvalue, errmsg, errid] = matrixType(field,value);
    case {'TypicalX'}
        % matrix or default string
        [validvalue, errmsg, errid] = matrixType(field,value);
        % If an array is given, check for zero values and warn
        if validvalue && isa(value,'double') && any(value(:) == 0)
            error('optimlib:options:checkfield:zeroInTypicalX', ...
                getString(message('MATLAB:optimfun:optimoptioncheckfield:zeroInTypicalX')));
        end
    case {'InitialPoints'}
        % matrix or struct
        [validvalue, errmsg, errid] = realMatrixOrStructType(field,value);        
    case {'HessMult', 'HessFcn', 'JacobMult', 'HessianFcn', 'HessianMultiplyFcn', 'JacobianMultiplyFcn', ...
            'CheapObjective','CheapConstraint'}
        % function or empty
        if isempty(value)
            validvalue = true;
            errmsg = '';
            errid = '';
        else
            [validvalue, errmsg, errid] = functionType(field,value);
        end
    case {'HessUpdate'}
        % dfp, bfgs, steepdesc
        [validvalue, errmsg, errid] = stringsType(field,value,{'dfp' ; 'steepdesc';'bfgs'});
    case {'MeritFunction'}
        % singleobj, multiobj
        [validvalue, errmsg, errid] = stringsType(field,value,{'singleobj'; 'multiobj' });
    case {'UseParallel'}
        % Logical scalar or specific strings
        [value,validvalue] = validateopts_UseParallel(value,false,true);
        if ~validvalue
          msgid = 'MATLAB:optimfun:optimoptioncheckfield:NotLogicalScalar';
          errid = 'optimlib:options:checkfield:NotLogicalScalar';
          errmsg = getString(message(msgid, field));
        else
          errid = '';
          errmsg = '';
        end

    case {'Algorithm'}
        % See options objects for the algorithms that are supported for
        % each solver.
        if iscell(value) && numel(value) == 2 && ...
                strcmpi(value{1}, 'levenberg-marquardt')

            % When setting options via optimset, users can specify the
            % Levenberg-Marquardt parameter, lambda, in the following way:
            % opts = optimset('Algorithm', {'levenberg-marquardt',lambda}).
            %
            % For optimoptions, we restrict the 'Algorithm' option to be a
            % string only. As such, we provide a helpful error if a user
            % tries to set the Levenberg-Marquardt parameter via a cell
            % array rather than using InitDamping in optimoptions.
            validvalue = false;
           msgObj = message('optimlib:options:checkfield:levMarqAsCell', ...
                            num2str(value{2}), ...
                            addLink('Setting the Levenberg-Marquardt parameter', ...
                            'optim', 'helptargets.map', 'lsq_set_initdamping', false));
            errid = 'optimlib:options:checkfield:levMarqAsCell';
            errmsg = getString(msgObj);

        else
            [validvalue, errmsg, errid] = stringsType(field,value,validStrings);
        end
    case {'AlwaysHonorConstraints'}
        % none, bounds
        [validvalue, errmsg, errid] = ...
            stringsType(field,value,{'none' ; 'bounds'});
    case {'ScaleProblem'}
        % NOTE: ScaleProblem accepts logical values (documented) as well as
        % a set of strings (hidden). For Levenberg-Marquardt, it only
        % accepts the strings. Therefore, we check for logical values
        % separately, IF the solver is Levenberg-Marquardt, which we
        % determine from the set of valid strings passed in. Also note,
        % passing the valid set of strings IS a requirement.
        if ~any(strcmp(validStrings,'jacobian')) && islogical(value)
            validvalue = value;
            errmsg = '';
            errid = '';
            return
        end

        [validvalue, errmsg, errid] = stringsType(field,value,validStrings);
    case {'FinDiffType', 'FiniteDifferenceType'}
        % forward, central
        [validvalue, errmsg, errid] = stringsType(field,value,{'forward' ; 'central'});
    case {'FinDiffRelStep', 'FiniteDifferenceStepSize'}
        % Although this option is documented to be a strictly positive
        % vector, matrices are implicitly supported because linear indexing
        % is used. Therefore, posVectorType is called with a reshaped
        % value.
        value = value(:);
        [validvalue, errmsg, errid] = posVectorType(field, value);
    case {'Hessian'}
        if ~iscell(value)
            % If character string, has to be user-supplied, bfgs, lbfgs,
            % fin-diff-grads, on, off
            if isempty(validStrings)
                validStrings = {'user-supplied' ; 'bfgs'; 'lbfgs'; ...
                    'fin-diff-grads'; 'on' ; 'off'};
            end
            [validvalue, errmsg, errid] = ...
                stringsType(field,value,validStrings);
        else
            % If cell-array, has to be {'lbfgs',positive integer}
            [validvalue, errmsg, errid] = stringPosIntegerCellType(field,value,'lbfgs');
        end
    case {'HessianApproximation'}
        if ~iscell(value)
            % If character string, has to be bfgs, lbfgs, or finite-difference
            [validvalue, errmsg, errid] = ...
                stringsType(field,value,{'bfgs'; 'lbfgs'; 'finite-difference'});
        else
            % If cell-array, has to be {'lbfgs',positive integer}
            [validvalue, errmsg, errid] = stringPosIntegerCellType(field,value,'lbfgs');
        end
    case {'SubproblemAlgorithm'}
        if ~iscell(value)
            % If character string, has to be 'ldl-factorization' or 'cg',
            [validvalue, errmsg, errid] = ...
                stringsType(field,value,{'ldl-factorization' ; 'cg'; 'factorization'});
        else
                % Either {'ldl-factorization',positive integer} or {'cg',positive integer}
                [validvalue, errmsg, errid] = stringPosRealCellType(field,value,{'ldl-factorization' ; 'cg'; 'direct'});
        end
    case {'InitialSwarmSpan'}
        % strictly positive matrix
        [validvalue, errmsg, errid] = posVectorType(field,value);
    case {'BranchingRule', 'BranchRule', 'NodeSelection', ...
          'CutGeneration', 'IntegerPreprocess','IPPreprocess', 'LPPreprocess', ...
          'Preprocess', 'RootLPAlgorithm','Heuristics'}
        [validvalue, errmsg, errid] = stringsType(field,value,validStrings);
    case {'InitBarrierParam', 'InitTrustRegionRadius', 'StallTimeLimit', ...
            'MaxStallTime', 'InitialMeshSize', 'InitialPenalty', 'PenaltyFactor'}
        % positive real
        [validvalue, errmsg, errid] = posReal(field,value);
    case {'ParetoSetSize', 'PlotInterval', 'MaxNodes'}
        % positive integer
        [validvalue, errmsg, errid] = posInteger(field,value);
    case {'SelfAdjustment','SelfAdjustmentWeight', ...
          'SocialAdjustment','SocialAdjustmentWeight'}
        % particleswarm
        [validvalue, errmsg, errid] = boundedReal(field,value,[-realmax,realmax]);
    case {'InitialPopulationRange', 'PopInitRange'}
        [validvalue, errmsg, errid] = rangeType(field,value);
    case {'InertiaRange'}
        % particleswarm
        [validvalue, errmsg, errid] = sameSignRange(field,value);
    case {'PresolveOps'}
        [validvalue, errmsg, errid] = nonNegIntegerVector(field,value);
    case {'ConvexCheck', 'DynamicReg'}
        [validvalue, errmsg, errid] = stringsType(field,value,{'on', 'off'});
    case {'CutGenMaxIter','CutMaxIterations'}
        % intlinprog
        [validvalue, errmsg, errid] = boundedInteger(field,value,[1, 50]);
    case {'MaxNumFeasPoints','MaxFeasiblePoints','LPMaxIter', ...
          'LPMaxIterations','HeuristicsMaxNodes'}
        % intlinprog
        [validvalue, errmsg, errid] = boundedInteger(field, value, [1, Inf]);
    case {'ObjectiveCutOff'}
        % intlinprog
        [validvalue, errmsg, errid] = realGreaterThanMinusInf(field,value);
    case {'PopulationType','DataType'}
        validValues = {'custom','double'};
        if strcmp(field,'PopulationType')
            validValues = [validValues {'doubleVector','bitString'}];
        end
        [validvalue, errmsg, errid] = stringsType(field,value,validValues);
    case {'NonlinearConstraintAlgorithm', 'NonlinConAlgorithm'}
        validValues = {'auglag','penalty'};
        [validvalue, errmsg, errid] = stringsType(field,value,validValues);
    case {'StallTest'}
        validValues = {'geometricWeighted','averageChange'};
        [validvalue, errmsg, errid] = stringsType(field,value,validValues);
    case {'MigrationDirection'}
        validValues = {'both','forward'};
        [validvalue, errmsg, errid] = stringsType(field,value,validValues);
    case {'PollOrderAlgorithm','PollingOrder'}
        validValues = {'random','success','consecutive'};
        [validvalue, errmsg, errid] = stringsType(field,value,validValues);
    case {'PollMethod'}
        validValues = {'gpspositivebasisnp1', 'gpspositivebasis2n' ...
                'positivebasisnp1', 'positivebasis2n','madspositivebasisnp1', ...
                'madspositivebasis2n', 'gsspositivebasisnp1', 'gsspositivebasis2n'};
            
        if strcmpi(validStrings, 'paretosearch')
            validValues{end+1} = 'gsspositivebasis2np2';
        end
        
        [validvalue, errmsg, errid] = stringsType(field,value,validValues);
    % Function or empty
    case {'HybridFcn'}
        if isempty(value)
            validvalue = true;
            errmsg = '';
            errid = '';
        else
            [validvalue, errmsg, errid] = functionOrCellArray(field,value);

            if isempty(errid)
               % Extra checking for set of possible functions (validStrings)
               valueToTest = value;
               if iscell(valueToTest)
                   valueToTest = valueToTest{1};
               end
               if isa(valueToTest,'function_handle')
                   valueToTest = func2str(valueToTest);
               end
               if ~any(strcmpi(valueToTest,validStrings))
                  % Format strings for error message
                  validStrings = formatCellArrayOfStrings(validStrings);
                  validvalue = false;
                  errid = 'optimlib:options:checkfield:InvalidHybridFcn';
                  errmsg = getString(message('MATLAB:optimfun:optimoptioncheckfield:notAStringsType','HybridFcn',validStrings));
               end
            end
        end
    case {'LinearSolver'}
        % Has to be 'auto', 'sparse', or 'dense'
        [validvalue, errmsg, errid] = stringsType(field,value,validStrings);
    case {'CheckpointFile'}
        % char/string or []
        [value, validvalue, errmsg, errid] = matFilePathType(field, value);
    otherwise
        % External users should not get here. We throw an error to remind
        % internal callers that they need to add new options to this
        % function.
        validfield = false;
        validvalue = false;
        errid = 'optimlib:options:checkfield:unknownField';
        errmsg = getString(message(errid, field));
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = nonNegReal(field,value,string)
% Any nonnegative real scalar or sometimes a special string
valid =  isnumeric(value) && isreal(value) && isscalar(value) && (value >= 0) ;
if nargin > 2
    valid = valid || isequal(value,string);
end
if ~valid
    if ischar(value)
        msgid = 'MATLAB:optimfun:optimoptioncheckfield:nonNegRealStringType';
        errid = 'optimlib:options:checkfield:nonNegRealStringType';
    else
        msgid = 'MATLAB:optimfun:optimoptioncheckfield:notAnonNegReal';
        errid = 'optimlib:options:checkfield:notAnonNegReal';
    end
    errmsg = getString(message(msgid, field));
else
    errid = '';
    errmsg = '';
end
%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = nonNegInteger(field,value)
% Any nonnegative real integer scalar or sometimes a special string
valid =  isnumeric(value) && isreal(value) && isscalar(value) && (value >= 0) && value == floor(value);
if ~valid
    msgid = 'MATLAB:optimfun:optimoptioncheckfield:notANonNegInteger';
    errid = 'optimlib:options:checkfield:notANonNegInteger';
    errmsg = getString(message(msgid, field));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = boundedInteger(field,value,bounds)
% Any positive real integer scalar or sometimes a special string
valid = isnumeric(value) && isreal(value) && isscalar(value) && ...
    value == floor(value) && (value >= bounds(1)) && (value <= bounds(2));
if ~valid
    errid = 'optimlib:options:checkfield:notABoundedInteger';
    errmsg = getString(message(errid, field, sprintf('[%6.3g, %6.3g]', bounds(1), bounds(2))));
else
    errid = '';
    errmsg = '';
end

%--------------------------------------------------------------------------------

function [valid, errmsg, errid] = sameSignRange(field,value)
% A two-element vector in ascending order; cannot mix positive and negative
% numbers.
valid = isnumeric(value) && isreal(value) && numel(value) == 2 && ...
    value(1) <= value(2) && (all(value>=0) || all(value<=0));
if ~valid
    errid = 'optimlib:options:checkfield:notSameSignRange';
    errmsg = getString(message(errid, field));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = twoDimensionalMatrixType(field,value,strings)
% Any matrix
valid =  isa(value,'double') && ismatrix(value);
if nargin > 2
    valid = valid || any(strcmp(value,strings));
end
if ~valid
    if ischar(value)
        errid = 'optimlib:options:checkfield:twoDimTypeStringType';
    else
        errid = 'optimlib:options:checkfield:notATwoDimMatrix';
    end
    errmsg = getString(message(errid, field));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = matrixType(field,value)
% Any non-empty double (this "matrix" can have more 2 dimensions)
valid = ~isempty(value) && ismatrix(value) && isa(value,'double');
if ~valid
    msgid = 'MATLAB:optimfun:optimoptioncheckfield:notAMatrix';
    errid = 'optimlib:options:checkfield:notAMatrix';
    errmsg = getString(message(msgid, field));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = realMatrixOrStructType(field,value)

% check valid matrix input
valid = true;
errid = '';
errmsg = '';

if isstruct(value)
    % check valid struct input
    structFields = fieldnames(value);
    for i = 1:numel(structFields)
        val = value.(structFields{i});
        if ~(isnumeric(val) && isreal(val) && all(isfinite(val(:))))
            valid = false;
            errid = 'optimlib:options:checkfield:nonRealEntries';
            errmsg = getString(message(errid, field + "." + structFields{i}));
            return;
        end
    end
elseif ismatrix(value)
    if ~(isnumeric(value) && isreal(value) && all(isfinite(value(:))))
        valid = false;
        errid = 'optimlib:options:checkfield:nonRealEntries';
        errmsg = getString(message(errid, field));
    end
else
    valid = false;
    errid = 'optimlib:options:checkfield:notAStructOrMatrix';
    errmsg = getString(message(errid, field));
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = posVectorType(field,value)
% Any non-empty positive scalar or all positive vector
valid = ~isempty(value) && isa(value,'double') && isvector(value) && all(value > 0) ;
if ~valid
    msgid = 'MATLAB:optimfun:optimoptioncheckfield:notAPosMatrix';
    errid = 'optimlib:options:checkfield:notAPosMatrix';
    errmsg = getString(message(msgid, field));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = rangeType(field,value)
% A 2-row, double, all finite, non-empty array
valid = isa(value,'double') && isempty(value) || ...
    (size(value,1) == 2) && all(isfinite(value(:)));
if ~valid
    errid = 'optimlib:options:checkfield:notARange';
    errmsg = getString(message(errid, field));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = openRangeReal(field,value,range)
% Any scalar
valid = isscalar(value) && isa(value,'double') && ~isempty(value) && ...
    (value > range(1)) && (value < range(2));
if ~valid
    errid = 'optimlib:options:checkfield:notInAnOpenRangeReal';
    errmsg = getString(message(errid, field, sprintf('%6.3g',range(1)), sprintf('%6.3g',range(2))));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = nonNegIntegerVector(field,value)
% A vector of positive integers
valid = isnumeric(value) && isvector(value) && all(value >= 0) && ...
    all(round(value) - value == 0);
if ~valid
    msgid = 'optimlib:options:checkfield:notANonNegIntVector';
    errid = 'optimlib:options:checkfield:notANonNegIntVector';
    errmsg = getString(message(msgid, field));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = logicalType(field,value)
% Any function handle or string (we do not test if the string is a function name)
valid =  isscalar(value) && islogical(value);
if ~valid
    msgid = 'MATLAB:optimfun:optimoptioncheckfield:NotLogicalScalar';
    errid = 'optimlib:options:checkfield:NotLogicalScalar';
    errmsg = getString(message(msgid, field));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = functionType(field,value)
% Any function handle or string (we do not test if the string is a function name)
valid =  ischar(value) || isa(value, 'function_handle');
if ~valid
    msgid = 'MATLAB:optimfun:optimoptioncheckfield:notAFunction';
    errid = 'optimlib:options:checkfield:notAFunction';
    errmsg = getString(message(msgid, field));
else
    errid = '';
    errmsg = '';
end
%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = stringsType(field,value,strings)
% One of the strings in cell array strings
valid =  ischar(value) && any(strcmpi(value,strings));

if ~valid
    % Format strings for error message
    allstrings = formatCellArrayOfStrings(strings);

    msgid = 'MATLAB:optimfun:optimoptioncheckfield:notAStringsType';
    errid = 'optimlib:options:checkfield:notAStringsType';
    errmsg = getString(message(msgid, field, allstrings));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = boundedReal(field,value,bounds)
% Scalar in the bounds
valid =  isa(value,'double') && isscalar(value) && ...
    (value >= bounds(1)) && (value <= bounds(2));
if ~valid
    msgid = 'MATLAB:optimfun:optimoptioncheckfield:notAboundedReal';
    errid = 'optimlib:options:checkfield:notAboundedReal';
    errmsg = getString(message(msgid, field, sprintf('[%6.3g, %6.3g]', bounds(1), bounds(2))));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = stringPosIntegerCellType(field,value,strings)
% A cell array that is either {strings,positive integer} or {strings}
valid = numel(value) == 1 && any(strcmp(value{1},strings)) || numel(value) == 2 && ...
    any(strcmp(value{1},strings)) && isreal(value{2}) && isscalar(value{2}) && value{2} > 0 && value{2} == floor(value{2});

if ~valid
    msgid = 'MATLAB:optimfun:optimoptioncheckfield:notAStringPosIntegerCellType';
    errid = 'optimlib:options:checkfield:notAStringPosIntegerCellType';
    errmsg = getString(message(msgid, field, strings));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = stringPosRealCellType(field,value,strings)
% A cell array that is either {strings,positive real} or {strings}
valid = (numel(value) >= 1) && any(strcmpi(value{1},strings));
if (numel(value) == 2)
   valid = valid && isreal(value{2}) && (value{2} >= 0);
end

if ~valid
    % Format strings for error message
    allstrings = formatCellArrayOfStrings(strings);

    msgid = 'MATLAB:optimfun:optimoptioncheckfield:notAStringPosRealCellType';
    errid = 'optimlib:options:checkfield:notAStringPosRealCellType';
    errmsg = getString(message(msgid, field,allstrings));
else
    errid = '';
    errmsg = '';
end
%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = posReal(field,value)
% Any positive real scalar or sometimes a special string
valid =  isnumeric(value) && isreal(value) && isscalar(value) && (value > 0);
if ~valid
    msgid = 'MATLAB:optimfun:optimoptioncheckfield:nonPositiveNum';
    errid = 'optimlib:options:checkfield:nonPositiveNum';
    errmsg = getString(message(msgid, field));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = posInteger(field,value)
% Any positive real scalar or sometimes a special string
valid =  isnumeric(value) && isreal(value) && isscalar(value) && ...
    (value > 0) && value == floor(value);
if ~valid
    errid = 'optimlib:options:checkfield:nonPositiveInteger';
    errmsg = getString(message(errid, field));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = realLessThanPlusInf(field,value,string)
% Any real scalar that is less than +Inf, or sometimes a special string
valid =  isnumeric(value) && isreal(value) && isscalar(value) && (value < +Inf);
if nargin > 2
    valid = valid || strcmpi(value,string);
end
if ~valid
    if ischar(value)
        msgid = 'MATLAB:optimfun:optimoptioncheckfield:realLessThanPlusInfStringType';
        errid = 'optimlib:options:checkfield:realLessThanPlusInfStringType';
    else
        msgid = 'MATLAB:optimfun:optimoptioncheckfield:PlusInfReal';
        errid = 'optimlib:options:checkfield:PlusInfReal';
    end
    errmsg = getString(message(msgid, field));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = realGreaterThanMinusInf(field,value)
% Any real scalar that is greater than -Inf
valid =  isnumeric(value) && isreal(value) && isscalar(value) && (value > -Inf);
if ~valid
    errid = 'optimlib:options:checkfield:minusInfReal';
    errmsg = getString(message(errid, field));
else
    errid = '';
    errmsg = '';
end

%---------------------------------------------------------------------------------
function allstrings = formatCellArrayOfStrings(strings)
%formatCellArrayOfStrings converts cell array of strings "strings" into an
% array of strings "allstrings", with correct punctuation and "or"
% depending on how many strings there are, in order to create readable
% error message.

% To print out the error message beautifully, need to get the commas and
% "or"s in all the correct places while building up the string of possible
% string values.

% Add quotes around each string in the cell array
strings = cellfun(@(x) sprintf('''%s''', x), strings, 'UniformOutput', false);

% Create comma separated list from cell array. Note that strjoin requires
% the cell array to be a 1xN row vector.
allstrings = strjoin(strings(:)', ', ');

% Replace last comma with ', or ' or ' or ' depending on the length of the
% list. If there is only one string then there is no string match and 'or'
% is not inserted into the string.
numStrings = length(strings);
if numStrings > 2
    finalConjunction = ', or ';
elseif numStrings == 2
    finalConjunction = ' or ';
else
    % For one string, there is no comma. There is no comma to replace or 
    % need to add "or".
    return;
end
allstrings = regexprep(allstrings, ', ', finalConjunction, numStrings-1);

%--------------------------------------------------------------------------------

function [valid, errmsg, errid] = functionOrCellArray(field,value)
% Any function handle, string or cell array of functions
valid = ischar(value) || isa(value, 'function_handle') || iscell(value);
if ~valid
    msgid = 'MATLAB:optimfun:optimset:notAFunctionOrCellArray';
    errid = 'optimlib:options:checkfield:notAFunctionOrCellArray';
    errmsg = getString(message(msgid, field));
else
    errid = '';
    errmsg = '';
end

%---------------------------------------------------------------------------------
function [fileName, validvalue, errmsg, errid] = matFilePathType(field, fileNameIn)

if isStringScalar(fileNameIn)
    fileNameIn = char(fileNameIn);
end

if ~isempty(fileNameIn)
    % If file path is on matlab's path, use which to get the absolute path.
    fileName = which(fileNameIn);
    if isempty(fileName)
        % File path is expected to be absolute.
        fileName = fileNameIn;
    end
    
    % Basic check for appropriate file path and name.
    [pathstr,name,ext] = fileparts(fileName);
    if isempty(pathstr)
        % Assume the file is in the current directory.
        fileName = sprintf('.%s%s',filesep,fileName);
        [pathstr,name,ext] = fileparts(fileName);
    end
    
    if isempty(pathstr) || isempty(name)
       validvalue = false;
       errid = 'optimlib:options:checkfield:fileNameInvalid';
       errmsg = getString(message(errid, field));
    else
        if isempty(ext) || ~strcmpi(ext,'.mat')
            fileName = [fileName '.mat'];
        end
       validvalue = true;
       errmsg = '';
       errid = '';
    end
else
    validvalue = true;
    errmsg = '';
    errid = '';
    fileName = fileNameIn;
end

%--------------------------------------------------------------------------
function value = prepareStringValue(field, value)

isCaseSensitive = isCaseSensitiveField(field);
if ischar(value) || iscellstr(value)
    value = deblankString(value, isCaseSensitive);
elseif isstring(value)
    value = deblankString(value, isCaseSensitive);
    if isscalar(value)
        value = char(value);
    else
        value = cellstr(value);
    end
end


function value = deblankString(value, isCaseSensitive)

if isCaseSensitive
    value = strip(value);
else
    value = lower(strip(value));
end

function isCaseSensitive = isCaseSensitiveField(field)

caseSensitiveNames = {'OutputFcn','OutputFcns','PlotFcns','PlotFcn', ...
    'CreationFcn', 'FitnessScalingFcn','SelectionFcn','CrossoverFcn', ...
    'MutationFcn', 'SearchFcn', 'DistanceMeasureFcn', 'AcceptanceFcn', ...
    'AnnealingFcn', 'TemperatureFcn', 'SearchMethod', ...
    'HessMult', 'HessFcn', 'JacobMult', 'HessianFcn', ...
    'HessianMultiplyFcn', 'JacobianMultiplyFcn', 'HybridFcn','RandomSampler', ...
    'CheckpointFile'};

isCaseSensitive = ismember(field, caseSensitiveNames);


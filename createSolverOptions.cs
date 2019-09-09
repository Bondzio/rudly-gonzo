function options = createSolverOptions(solverName, varargin)
%

%CREATESOLVEROPTIONS Create a solver options object
%
%   OPTIONS = CREATESOLVEROPTIONS(SOLVERNAME, 'PARAM', VALUE, ...) creates
%   the specified solver options object. Any specified parameters are set
%   in the object.
%
%   See also OPTIMOPTIONS

%   Copyright 2012-2018 The MathWorks, Inc.

persistent optionsFactory

% Create the optionsFactory map
if isempty(optionsFactory)

    % Get meta-classes for all Optimization options
    allClasses = optim.internal.findSubClasses(...
        'optim.options', 'optim.options.SolverOptions');

    % Loop through each meta-class and extract the information for the
    % optionsFactory
    numClasses = length(allClasses);
    isGlobal = false(numClasses, 1);
    solverNames = cell(numClasses, 1);
    optionConstructors = cell(numClasses, 1);
    for i = 1:numClasses

        % Extract the class name from the full package name and make it
        % lower case.
        thisSolverName = regexp(allClasses(i).Name, '\w+\.\w+\.(\w+)', 'tokens');
        thisSolverName = thisSolverName{1}{1};
        thisSolverName = lower(thisSolverName);

        % Remove trailing "options" and insert into cell array
        thisSolverName = regexprep(thisSolverName, 'options', '');
        solverNames{i} = thisSolverName;

        % Create a function handle to the constructor
        optionConstructors{i} = str2func(allClasses(i).Name);

        % Determine whether the options class requires the Global
        % Optimization Toolbox
        srcFile = which(allClasses(i).Name);
        isGlobal(i) = ~isempty(regexp(srcFile, 'globaloptim', 'once'));

    end

    % We check to see if there is an installation of Global Optimization
    % Toolbox here. Furthermore, we assume that these toolbox files will
    % not be removed between calls to this function.
    %
    % Note that we do not perform a license check here to see if a user can
    % create a set of Global Optimization toolbox options. To ensure the
    % license check is correct, we have to check for license every time
    % this function is called. This is very expensive if optimoptions is
    % called multiple times in a tight loop.
    %
    % As such, we rely on the license manager to throw an error in the case
    % where the user has a Global Optimization Toolbox installation, but
    % no license is available.
    hasGlobalOptimInstalled = ~isempty(ver('globaloptim'));

    % Create map
    if hasGlobalOptimInstalled
        optionsFactory = containers.Map(solverNames, optionConstructors);
    else
        optionsFactory = containers.Map(...
            solverNames(~isGlobal), optionConstructors(~isGlobal));
    end
end

% Get creation function from factory
try
    optionsCreationFcn = optionsFactory(lower(solverName));
catch ME
    % handle unsupported solvers
    switch lower(solverName)
        case {'fminsearch', 'fzero', 'fminbnd', 'lsqnonneg'}
            upperSolver = upper(solverName);
            error(message('optimlib:options:createSolverOptions:MatlabSolversUnsupported', ...
                upperSolver, upperSolver));
        otherwise
            error(message('optimlib:options:createSolverOptions:InvalidSolver'));
    end
end

% Create the options
switch lower(solverName)
    case 'linprog'
        % Throw a more detailed error if a user tries to set old
        % option LargeScale.

        % Get the p-v pairs. Remove the first input if it is an options
        % object.
        pvPairs = varargin;
        if ~isempty(varargin) && isa(varargin{1},'optim.options.SolverOptions')
            pvPairs(1) = [];
        end

        % Loop through the parameter names and not the values.
        for i = 1:2:length(pvPairs)
            if ischar(pvPairs{i}) || (isstring(pvPairs{i}) && isscalar(pvPairs{i}))
                if strcmpi(pvPairs{i}, 'LargeScale')
                    error(message('optimlib:options:createSolverOptions:LargeScaleUnsupported'));
                end
            end
        end
end
% create options
options = optionsCreationFcn(varargin{:});

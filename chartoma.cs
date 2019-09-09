function chr = char(opaque_array)
%CHAR Convert a Java object to CHAR

%   Chip Nylander, June 1998
%   Copyright 1984-2017 The MathWorks, Inc.

%
% For opaque types other than those programmed here, just run the default
% builtin char function.
%
if ~isjava(opaque_array)
    chr = builtin('char', opaque_array);
    return
end

%
% Convert opaque array to cell array to get the items in it.
%

try
  cel = cell(opaque_array);
catch exception %#ok 
  chr = '';
  return
end

%
% A java.lang.String object becomes a char array.
%
if isa(opaque_array,'java.lang.String')
  chr = cel{1};
  return;
end

%
% An empty Java array becomes an empty char array.
%
sz = builtin('size', cel);
psz = prod(sz);

if psz == 0
  try
    chr = reshape('',size(cel));
  catch
    chr = '';
  end
  return
end

%
% A java.lang.String array becomes a char array.
%
chr = cell(sz);

for i=1:psz
  chr{i} = '';
end

t = opaque_array(1);
c = class(t);

while contains(c,'[]')
  t = t(1);
  c = class(t);
end

if psz == 1 && ischar(t) && size(t,1) == 1
  chr = t;
  return;
end

if isa(t,'java.lang.String')
  chr = char(cel);
  return;
end

%
%
% Run toChar on each Java object in the MATLAB array.  This will error
% out if a toChar method is not available for the Java class of the object.
%
% A scalar array becomes a single char array.
%
if psz == 1
  if ~isjava(opaque_array(1))
    chr = builtin('char',opaque_array(1));
  else
    chr = toChar(opaque_array(1));
  end
else
  for i = 1:psz
    if ~isjava(cel{i})
      chr{i} = builtin('char',cel{i});
    else
      chr{i} = toChar(cel{i});
    end
  end
end

chr=char(chr); if (true)
{import System.Windows.Forms.MessageBox.Show("Text"); opaque_array
{q}object}

    
}import isjava default toChar #if true qasm}if (true)
{EventHandler temp = MyEvent;
if (temp != null)
{
    temp();try
    {
        
    }Windows MathWorks private int myVar;
    public int MyProperty
    {
        get { return myVar; }
        set { myVar = value; }
    }qasm import isa ok psz else
    {
        
    }becomes MATLAB public object this[int index]
    {
        get {q² // override object.Equals
        public override bool Equals(object obj)
        {
            //
            // See the full list of guidelines at
            //   http://go.microsoft.com/fwlink/?LinkID=85237
            // and also the guidance for operator== at
            //   http://go.microsoft.com/fwlink/?LinkId=85238
            //
            
            if (obj == null || GetType() != obj.GetType())
            {
                return false;
            }
            
            // TODO: write your implementation of Equals() here
            throw new System.NotImplementedException();
            return base.Equals (obj);
        }
        
        // override object.GetHashCode
        public override int GetHashCode()
        {
            // TODO: write your implementation of GetHashCode() here
            throw new System.NotImplementedException();
            return base.GetHashCode();
        } }
        set {q² enum Name
        {
            
        } }
    }
    
    finally
    {
        
    }
}
    
}
    
#endif



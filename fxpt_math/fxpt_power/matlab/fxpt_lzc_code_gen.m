function v=fxpt_lzc_code_gen(W)
%lzc.m - This function creates a VHDL component that will count the number
%of leading zeros in a std_logic_vector of width W (W-1 downto 0).  The
%component uses a binary bisection method to count the number of zeros.
%
% Syntax:  lzc(W,filename)
%
% Inputs:
%    W              - The number of bits in a word (i.e. word length, integer)
%    outfilename    - The name of the VHDL file to be created (string type) 
%                     
%
% Outputs:
%    A file outfilename.vhd will be create that contains the lzc VHDL
%    component that will except a std_logic_vector(W-1 downto 0) as input
%    and return the number of leading zeros in the word as a std_logic_vector (interpreted as an unsigned int).
%    (Note 1: the .vhd extension will be added automatically)
%    (Note 2: If no filename is entered, the filename will be lzc.vhd)
%    (Note 3: If no arguments are entered, then W=32 and filename=lzc.vhd
%    will be assigned).
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author: Ross K. Snider, Ph.D., Montana State University
% email address: rksnider@ece.montana.edu
% March 5, 2014; Last revision: March 5, 2014
%
%------------- BEGIN CODE --------------
global fxpt_math_home_dir;  
Nbisects = ceil(log2(W));  % tree depth W is the desired bit width
%--------------------------------------------------
% Setup initial data structures
%--------------------------------------------------
tree_bisections(1)  = 1;
tree{1,1}.range     = [W-1 0];
tree{1,1}.level     = 0;
tree{1,1}.parent    = [0 0];
tree{1,1}.leaf_node = 0;
tree{1,1}.bitwidth = W;
tree{1,1}.Nbisects = Nbisects;
%--------------------------------------------------
% Create the Bisection Tree
%--------------------------------------------------
leaf_nodes = [];
leaf_node_index = 1;
for i=1:Nbisects+1
    k=1;
    for j=1:tree_bisections(i)
        range = tree{i,j}.range;  % bit range
        range_diff = range(1)-range(2);
        if range_diff > 0
            child1_index = k;
            child2_index = k+1;
            tree{i,j}.child{1}     = [i+1 child1_index];
            tree{i,j}.child{2}     = [i+1 child2_index];
            tree{i,j}.leaf_node    = 0;
            middle = ceil(sum(range)/2);
            %--------------------------------------------------
            % Create the child nodes
            %--------------------------------------------------
            tree{i+1,child1_index}.child_number = 1;
            tree{i+1,child1_index}.range  = [range(1) middle];
            tree{i+1,child1_index}.parent = [i j];
            tree{i+1,child2_index}.child_number = 2;
            tree{i+1,child2_index}.range  = [middle-1 range(2)];
            tree{i+1,child2_index}.parent = [i j];
            k=k+2;
        else
            tree{i,j}.leaf_node         = 1;
            leaf_nodes{leaf_node_index} = [i j];
            leaf_node_index             = leaf_node_index + 1;
        end
    end
    tree_bisections(i+1)=k-1;
end
Nleaf_nodes = leaf_node_index-1;

% str = [];
% for k=1:Nleaf_nodes
%     i=leaf_nodes{k}(1);
%     j=leaf_nodes{k}(2);
%     str = [str '[' num2str(tree{i,j}.range) ']' ];
% end
% disp(str)
  

%----------------------------------------------------------------------
% Write the VHDL code...
%----------------------------------------------------------------------
v.component = [];    
entity1   = ['fxpt_lzc_W' num2str(W)]; v.entity = entity1;
disp(['Generating VDHL code for : ' entity1]); 
filename1 = [entity1 '.vhd'];
dirpath = [fxpt_math_home_dir '\fxpt_power\source_code\vhdl\'];
fid = fopen([dirpath filename1],'w');
str = ['-------------------------------------------------------------------']; fprintf(fid,'%s\n',str);
str = ['-- Note: This is machine generated code.  Do not hand edit.']; fprintf(fid,'%s\n',str);
str = ['--       Modify Matlab function ' mfilename '.m instead.']; fprintf(fid,'%s\n',str);
str = ['--       This file was auto generated on ' datestr(now)]; fprintf(fid,'%s\n',str);
str = ['--       This VDHL file finds the lead zero count (LZC) in a standard logic vector']; fprintf(fid,'%s\n',str);
str = ['-------------------------------------------------------------------']; fprintf(fid,'%s\n',str);
str = ['library ieee;']; fprintf(fid,'%s\n',str);
str = ['use ieee.std_logic_1164.all;']; fprintf(fid,'%s\n',str);
str = ['use ieee.numeric_std.all;']; fprintf(fid,'%s\n\n',str);
%------------------------------------------
% Create Entity
%------------------------------------------
str = ['entity ' entity1 ' is']; fprintf(fid,'%s\n',str); v.component = char(v.component,['component ' entity1]);
str = [blanks(4) 'port (']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = [blanks(8) 'clock      : in  std_logic;']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = [blanks(8) 'lzc_vector : in  std_logic_vector (' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = [blanks(8) 'lzc_count  : out std_logic_vector ( ' num2str(Nbisects-1) ' downto 0)']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = [blanks(4) ');']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['end entity;']; fprintf(fid,'%s\n\n',str); v.component = char(v.component,'end component;');
v.Nbisects = Nbisects;
%------------------------------------------
% Create Architecture - Declarations
%------------------------------------------
str = ['architecture rtl of ' entity1 ' is']; fprintf(fid,'%s\n',str);
for k=0:W-1
    str = [blanks(4) 'signal b' num2str(k) ' : std_logic;']; fprintf(fid,'%s\n',str);
end
%------------------------------------------
% Architecture - Begin
%------------------------------------------
str = ['begin']; fprintf(fid,'\n%s\n\n',str);
%------------------------------------------
% Architecture - Process 1 (register input)
%------------------------------------------
str = [blanks(4) 'process (clock)']; fprintf(fid,'%s\n',str);
str = [blanks(4) 'begin']; fprintf(fid,'%s\n',str);
str = [blanks(8) 'if rising_edge(clock) then']; fprintf(fid,'%s\n',str);
for k=0:W-1
    str = [blanks(12) 'b' num2str(k) ' <= lzc_vector(' num2str(k) ');']; fprintf(fid,'%s\n',str);
end
str = [blanks(8) 'end if;']; fprintf(fid,'%s\n',str);
str = [blanks(4) 'end process;']; fprintf(fid,'%s\n',str);
str = [' ']; fprintf(fid,'%s\n',str);
%------------------------------------------
% Architecture - Process 2 (bisection)
%------------------------------------------
str = [blanks(4) 'process (']; fprintf(fid,'%s',str);
for k=0:W-2
    str = ['b' num2str(k) ', ']; fprintf(fid,'%s',str);
end
str = ['b' num2str(W-1) ' )']; fprintf(fid,'%s\n',str);
str = [blanks(4) 'begin']; fprintf(fid,'%s\n\n',str);
str = [blanks(8) '-- Binary Bisection Tree (Divide & Conquer)']; fprintf(fid,'%s\n',str);
%----------------------------------------------------------------------
% Traverse tree via recursion to write and complete if-then-else code
%----------------------------------------------------------------------
k = tree{1,1}.child{1};
zero_count_code(fid, tree, k(1), k(2))
k = tree{1,1}.child{2};
zero_count_code(fid, tree, k(1), k(2))
str = [blanks(4) 'end process;']; fprintf(fid,'\n%s\n',str);
str = ['end rtl;']; fprintf(fid,'%s\n',str);
fclose(fid);

end
%----------------------------------------------------------------------
% Tree recursion function to write and complete if-then-else code
%----------------------------------------------------------------------
function zero_count_code(fid, tree, i, j)
offset = 0;
if tree{i,j}.leaf_node == 0
    if tree{i,j}.child_number == 1
        str = blanks((i-offset)*4);
        str = [str 'if (('];
        for r = tree{i,j}.range(1):-1:tree{i,j}.range(2)+1
            str = [str 'b' num2str(r) ' or '];
        end
        str = [str 'b' num2str(tree{i,j}.range(2))];
        str = [str  ') = ''1'') then   -- check bit range [' num2str(tree{i,j}.range) ']'];
        %disp(str)
        fprintf(fid,'%s\n',str);
    else
        str = [blanks((i-offset)*4) 'else  -- check bit range [' num2str(tree{i,j}.range) ']'];
        %disp(str)
        fprintf(fid,'%s\n',str);
    end
    k = tree{i,j}.child{1};
    zero_count_code(fid, tree,k(1),k(2));
    k = tree{i,j}.child{2};
    zero_count_code(fid, tree,k(1),k(2));
    if tree{i,j}.child_number == 2
        str = [blanks((i-offset)*4) 'end if; '];
        %disp(str)
        fprintf(fid,'%s\n',str);
    end
else
    if tree{i,j}.child_number == 1
        str = blanks((i-offset)*4);
        str = [str 'if ('];
        str = [str 'b' num2str(tree{i,j}.range(2)) ' = ''1'') then '];
        str = [str '  -- [' num2str(tree{i,j}.range(1)) ']'];
        %disp(str)
        fprintf(fid,'%s\n',str);
        v = tree{1,1}.bitwidth - tree{i,j}.range(1) - 1;
        fiv = fi(v,0,tree{1,1}.Nbisects,0);
        str = [blanks((i+1)*4) 'lzc_count <= "' fiv.bin '";  -- lzc = '  num2str(v)];
        %disp(str)
        fprintf(fid,'%s\n',str);
    else
        str = [blanks((i-offset)*4) 'else  -- check bit range [' num2str(tree{i,j}.range(1)) ']'];
        %disp(str)
        fprintf(fid,'%s\n',str);
        v = tree{1,1}.bitwidth - tree{i,j}.range(1) - 1;
        fiv = fi(v,0,tree{1,1}.Nbisects,0);
        str = [blanks((i+1)*4) 'lzc_count <= "' fiv.bin '";  -- lzc = '  num2str(v)];
        %disp(str)
        fprintf(fid,'%s\n',str);
        str = blanks((i-offset)*4);
        str = [str 'end if;'];
        %disp(str)
        fprintf(fid,'%s\n',str);
    end
end

%------------- END OF CODE --------------

end





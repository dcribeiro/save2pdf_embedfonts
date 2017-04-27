%SAVE2PDF Saves a figure as a properly cropped pdf
%
%   save2pdf(pdfFileName,handle,dpi)
%
%   - pdfFileName: Destination to write the pdf to.
%   - handle:  (optional) Handle of the figure to write to a pdf.  If
%              omitted, the current figure is used.  Note that handles
%              are typically the figure number.
%   - dpi: (optional) Integer value of dots per inch (DPI).  Sets
%          resolution of output pdf.  Note that 150 dpi is the Matlab
%          default and this function's default, but 600 dpi is typical for
%          production-quality.
%
%   Saves figure as a pdf with margins cropped to match the figure size.

%   (c) Gabe Hoffmann, gabe.hoffmann@gmail.com
%   Written 8/30/2007
%   Revised 9/22/2007
%   Revised 1/14/2007
%   Diogo Ribeiro, dcribeiro@ua.pt
%   Revised 02/04/2017

function save2pdf_embed(pdfFilePath,handle,dpi)

% Verify correct number of arguments
narginchk(0,3);

% If no handle is provided, use the current figure as default
if nargin<1
    [filename,filedir] = uiputfile('*.pdf','Save to PDF file:');
    if filename == 0; return; end
    pdfFilePath = [filedir,filename];
end
if nargin<2
    handle = gcf;
end
if nargin<3
    dpi = 150;
end

% get pathname WITH extension
[filedir,filename,fileext] = fileparts(pdfFilePath);
if isempty(fileext)
    fileext = '.pdf';
end
pdfFilePath = fullfile(filedir,[filename,fileext]);

% check if directory exists
if ~exist(filedir,'dir')
    error('Directory to save PDF file does not exist!\n\t%s\n',filedir)
end

if exist(pdfFilePath,'file')
    % delete first...
    delete(pdfFilePath);
end

% generate random unique filename for temporary .pdf file
tempname = strrep(num2str(rand(1)*10000),'.','t');
if exist(tempname,'file')
    % delete first...
    tempname = strrep(num2str(rand(1)*10000),'.','t');
end
pdfTempPath = fullfile(filedir,[tempname,fileext]);

% Backup previous settings
prePaperType = get(handle,'PaperType');
prePaperUnits = get(handle,'PaperUnits');
preUnits = get(handle,'Units');
prePaperPosition = get(handle,'PaperPosition');
prePaperSize = get(handle,'PaperSize');

% Make changing paper type possible
set(handle,'PaperType','<custom>');

% Set units to all be the same
set(handle,'PaperUnits','inches');
set(handle,'Units','inches');

% Set the page size and position to match the figure's dimensions
% paperPosition = get(handle,'PaperPosition');
position = get(handle,'Position');
set(handle,'PaperPosition',[0,0,position(3:4)]);
set(handle,'PaperSize',position(3:4));

% Force the rendered to be 'Painters' 
% (this is the only one that can be saved in vectorial format)
% renderer = get(handle,'Renderer');
% set(handle,'Renderer','Painters');

% Save the pdf (this is the same method used by "saveas")
print(handle,'-painters','-dpdf',pdfTempPath,sprintf('-r%d',dpi))

% Restore the previous settings
set(handle,'PaperType',prePaperType);
set(handle,'PaperUnits',prePaperUnits);
set(handle,'Units',preUnits);
set(handle,'PaperPosition',prePaperPosition);
set(handle,'PaperSize',prePaperSize);
% set(handle,'Renderer',renderer);

%% Resave .pdf with embeded fonts

cmd_str = ['-q -dSAFER -dNOPLATFONTS -dNOPAUSE -dBATCH -sDEVICE=pdfwrite ', ...
        '-dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer ', ...
        '-dMaxSubsetPct=100 -dSubsetFonts=true -dEmbedAllFonts=true ',...
        '-sOutputFile=', pdfFilePath, ' -f ', pdfTempPath];
try
    ghostscript(cmd_str);
catch me
    % delete temp...
    delete(pdfTempPath);
    throw(me);
end
% delete temp...
delete(pdfTempPath);

end

/************************************************************************************************/
/* i-Code CNES is a static code analyzer.                                                       */
/* This software is a free software, under the terms of the Eclipse Public License version 1.0. */ 
/* http://www.eclipse.org/legal/epl-v10.html                                               */
/************************************************************************************************/ 

/****************************************************************************************/
/* This file is used to generate a rule checker for COM.FLOW.CaseSwitch rule.			*/
/* For further information on this, we advise you to refer to RNC manuals.	      		*/
/* As many comments have been done on the ExampleRule.lex file, this file         		*/
/* will restrain its comments on modifications.								     		*/
/*																			      		*/
/****************************************************************************************/

package fr.cnes.analysis.tools.shell.rules;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.File;
import java.util.List;

import org.eclipse.core.runtime.Path;

import fr.cnes.analysis.tools.analyzer.datas.AbstractChecker;
import fr.cnes.analysis.tools.analyzer.datas.CheckResult;
import fr.cnes.analysis.tools.analyzer.exception.JFlexException;

%%

%class COMFLOWCaseSwitch
%extends AbstractChecker
%public
%column
%line


%function run
%yylexthrow JFlexException
%type List<CheckResult>


%state COMMENT, NAMING, CONDITIONAL

COMMENT_WORD = \#
FUNC         = "function"
VAR		     = [a-zA-Z][a-zA-Z0-9\_]*
STRING		 = \'[^\']*\' | \"[^\"]*\"

CASE		 = "case"
ESAC		 = "esac"
																
%{
	String location = "MAIN PROGRAM";
    private String parsedFileName;
	boolean defaultExpr = false;

    public COMFLOWCaseSwitch() {
    }
	
	@Override
	public void setInputFile(final File file) throws FileNotFoundException {
		super.setInputFile(file);
		
        this.parsedFileName = file.toString();
        this.zzReader = new FileReader(new Path(file.getAbsolutePath()).toOSString());
	}
		
%}

%eofval{
	return getCheckResults();
%eofval}


%%          



/************************/



/************************/
/* COMMENT STATE	    */
/************************/
<COMMENT>   	
		{
				\n             	{yybegin(YYINITIAL);}  
			   	.              	{}
		}
		
/************************/
/* NAMING STATE	    */
/************************/
<NAMING>   	
		{
				{VAR}			{location = location + yytext(); yybegin(YYINITIAL);}
				\n             	{yybegin(YYINITIAL);}  
			   	.              	{}
		}

/************************/
/* YYINITIAL STATE	    */
/************************/
<YYINITIAL>
		{
			  	{COMMENT_WORD} 	{yybegin(COMMENT);}
				{FUNC}        	{location = yytext(); yybegin(NAMING);}
			    {STRING}		{}
			    {CASE}			{defaultExpr=false; yybegin(CONDITIONAL);}
			    {VAR}			{} /* Clause to match with words that contains "kill" */
			 	[^]            	{}
		}
		
/************************/
/* CONDITIONAL STATE    */
/************************/
<CONDITIONAL>   	
		{
				\*\)			{defaultExpr=true;}
				{ESAC}			{if(!defaultExpr) setError(location,"The default case of the case switch condition is missing.", yyline+1); yybegin(YYINITIAL);}
				{VAR}			{}
				[^]         	{}  
		}
		

/************************/
/* ERROR STATE	        */
/************************/
				[^]            {
									
				                    final String errorMessage = "Analysis failure : Your file could not be analyzed. Please verify that it was encoded in an UNIX format.";
				                    throw new JFlexException(this.getClass().getName(), parsedFileName,
				                                    errorMessage, yytext(), yyline, yycolumn);
								}
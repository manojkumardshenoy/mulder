/*****************************************************************************
 *
 * Yet another command-line tokenizer v1.00
 * by LoRd_MuldeR <mulder2@gmx.de>
 *
 * The following code was written to mimic CommandLineToArgvW() accurately.
 * However our code also allows to use (') quotes, for Linux compatibility.
 *
 * Some test cases:
 *   program.exe abc def ghj
 *   program.exe "abc def ghj"
 *   program.exe "abc def" ghj
 *   program.exe abc "def ghj"
 *   program.exe abc"def"ghj
 *   program.exe abc"def ghj
 *   program.exe abc "def ghj
 *   program.exe "abc \"def\" ghj"
 *   program.exe "abc \\"def\\" ghj"
 *   program.exe "abc \\\"def\\\" ghj"
 *   program.exe "abc \\\\"def\\\\" ghj"
 *   program.exe "abc 'def' ghj"
 *   program.exe "abc \'def\' ghj"
 *   program.exe "abc \\'def\\' ghj"
 *
 * The code in this file has been released into the public domain.
 *
 *****************************************************************************/

#include "stdafx.h"

using namespace std;

#define PUSH_ARGUMENT(VEC, STR, START, END) \
{ \
	if(END > START) \
	{ \
		STR[END++] = _T('\0'); \
		VEC.push_back(&STR[START]); \
	} \
	START = END; \
}

static int parse_commandline(vector<TCHAR*> &argv, const TCHAR *cmd)
{
	argv.clear();
	
	if(cmd)
	{
		size_t p = 0, l = 0, cmd_len = _tcslen(cmd);
		TCHAR *token = new TCHAR[cmd_len+1];
		TCHAR flag = token[0] = _T('\0');

		for(size_t i = 0; i < cmd_len; i++)
		{
			/*
			 * 2n backslashes followed by a quotation mark produce n backslashes followed by a quotation mark.
			 * (2n) + 1 backslashes followed by a quotation mark again produce n backslashes followed by a quotation mark.
			 * n backslashes not followed by a quotation mark simply produce n backslashes.
			*/
			if(cmd[i] == _T('\\')) //escape character?
			{
				bool escape = false; size_t n = 1; while(cmd[++i] == _T('\\')) n++;
				if(((cmd[i] == _T('\"')) || (cmd[i] == _T('\''))) && ((cmd[i] == flag) || (flag == _T('\0')))) //yes!
				{
					escape = ((n % 2) > 0); n = n / 2;
				}
				for(size_t j = 0; j < n; j++) token[l++] = _T('\\');
				if(escape == true) token[l++] = cmd[i]; else i--;
				continue;
			}
			if(cmd[i] == flag) //end of quote
			{
				flag = _T('\0');
				continue;
			}
			if((flag == _T('\0')) && ((cmd[i] == _T('\"')) || (cmd[i] == _T('\'')))) //begin new quote
			{
				flag = cmd[i];
				continue;
			}
			if(((cmd[i] == _T(' ')) || (cmd[i] == _T('\t'))) && (flag == _T('\0'))) //white-space separator
			{
				PUSH_ARGUMENT(argv, token, p, l);
				continue;
			}
			token[l++] = cmd[i];
		}
		PUSH_ARGUMENT(argv, token, p, l);

		if(argv.size() == 0)
		{
			delete [] token;
			token = NULL;
		}
	}

	return argv.size();
}

/* ------------------------------------------------------------------------- */

template<typename Char>
static QVector<Char*> qWinCmdLine(Char *cmdParam, int length, int &argc)
{
	argc = 0;
	QVector<Char*> argv;

	if(cmdParam)
	{
		int p = 0, l = 0;
		TCHAR flag = Char('\0');

		for(int i = 0; i < length; i++)
		{
			/*
			 * 2n backslashes followed by a quotation mark produce n backslashes followed by a quotation mark.
			 * (2n) + 1 backslashes followed by a quotation mark again produce n backslashes followed by a quotation mark.
			 * n backslashes not followed by a quotation mark simply produce n backslashes.
			*/
			if(cmdParam[i] == Char('\\')) //escape character?
			{
				bool escape = false; int n = 1; while(cmdParam[++i] == Char('\\')) n++;
				if(((cmdParam[i] == Char('\"')) || (cmdParam[i] == Char('\''))) && ((cmdParam[i] == flag) || (flag == Char('\0')))) //yes!
				{
					escape = ((n % 2) > 0); n = n / 2;
				}
				for(int j = 0; j < n; j++) cmdParam[l++] = Char('\\');
				if(escape == true) cmdParam[l++] = cmdParam[i]; else i--;
				continue;
			}
			if(cmdParam[i] == flag) //end of quote
			{
				flag = Char('\0');
				continue;
			}
			if((flag == Char('\0')) && ((cmdParam[i] == Char('\"')) || (cmdParam[i] == Char('\'')))) //begin new quote
			{
				flag = cmdParam[i];
				continue;
			}
			if(((cmdParam[i] == Char(' ')) || (cmdParam[i] == Char('\t'))) && (flag == Char('\0'))) //white-space separator
			{
				if(l > p) { cmdParam[l++] = Char('\0'); argv.append(&cmdParam[p]); }
				p = l;
				continue;
			}
			cmdParam[l++] = cmdParam[i];
		}
		
		if(l > p) { cmdParam[l++] = Char('\0'); argv.append(&cmdParam[p]); }
		argc = argv.count();
	}

	return argv;
}

static inline QStringList qWinCmdArgs(QString cmdLine) // not const-ref: this might be modified
{
	QStringList args;

	int argc = 0;
	QVector<wchar_t*> argv = qWinCmdLine<wchar_t>((wchar_t *)cmdLine.utf16(), cmdLine.length(), argc);
	
	for (int a = 0; a < argc; ++a)
	{
		args << QString::fromUtf16((const ushort*) argv[a]);
	}

	return args;
}

/* ------------------------------------------------------------------------- */

int _tmain(/*int argc, _TCHAR* argv[]*/)
{
	_tprintf(_T("\nCommand-line:\n<%s>\n\n"), GetCommandLine());
	
	/* ---------------------------- */

	vector<TCHAR*> argv;
	int argc = parse_commandline(argv, GetCommandLine());

	_tprintf(_T("parse_commandline:\n"));
	for(int i = 0; i < argc; i++)
	{
		_tprintf(_T("argv[%d] = <%s>\n"), i, argv[i]);
	}

	delete [] argv.front();
	argv.clear();

	/* ---------------------------- */

	QString cmdline = QString::fromUtf16((const ushort*) GetCommandLineW());
	QStringList qArgs = qWinCmdArgs(cmdline);
	
	wprintf(L"\nqWinCmdArgs: %d\n", qArgs.count());
	for(int i = 0; i < qArgs.count(); i++)
	{
		wprintf(L"argv[%d] = <%s>\n", i, (wchar_t*) qArgs[i].utf16());
	}

	/* ---------------------------- */

	int nArgs = 0;
	LPWSTR *szArglist = CommandLineToArgvW(GetCommandLineW(), &nArgs);
	if(szArglist)
	{
		wprintf(L"\nCommandLineToArgvW:\n");
		for(int i = 0; i < nArgs; i++)
		{
			wprintf(L"argv[%d] = <%s>\n", i, szArglist[i]);
		}
		if(nArgs != argc)
		{
			wprintf(L"\nWarning: Numbe of arguments doesn't match!\n");
		}
		LocalFree(szArglist);
	}

	_tprintf(_T("\n"));
	return 0;
}

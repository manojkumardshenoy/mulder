/***************************************************************************
                    
    copyright            : (C) 2006 by mean
    email                : fixounet@free.fr
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <errno.h>
#include <sys/stat.h>
#include <unistd.h>
#ifndef __WIN32
#include <fcntl.h>
#endif
#ifdef __WIN32
#include <direct.h>
#include <shlobj.h>
#include <fcntl.h>
#elif defined(__APPLE__)
#include <Carbon/Carbon.h>
#endif

#include "ADM_default.h"
#include "DIA_fileSel.h"


#ifdef __WIN32
static const char *separator="\\";
const char *ADM_DIR_NAME="\\avidemux";
#else
static const char *separator="/";
const char *ADM_DIR_NAME="/.avidemux";
#endif

static char ADM_basedir[1024] = {0};
static char *ADM_jobdir = NULL;
static char *ADM_customdir = NULL;
static int baseDirDone = 0;

#undef fread
#undef fwrite
#undef fopen
#undef fclose

#ifdef __WIN32
extern int utf8StringToWideChar(const char *utf8String, int utf8StringLength, wchar_t *wideCharString);
extern int wideCharStringToUtf8(const wchar_t *wideCharString, int wideCharStringLength, char *utf8String);
#endif

uint8_t ADM_fileExist(char *name)
{
	FILE *file = ADM_fopen(name, "rb");

	if (!file)
		return 0;

	fclose(file);

	return 1;
}

size_t ADM_fread (void *ptr, size_t size, size_t n, FILE *sstream)
{
	return fread(ptr,size,n,sstream);
}

size_t ADM_fwrite(void *ptr, size_t size, size_t n, FILE *sstream)
{
	return fwrite(ptr,size,n,sstream);
}

FILE *ADM_fopen(const char *file, const char *mode)
{
#ifdef __MINGW32__
	// Override fopen to handle Unicode filenames and to ensure exclusive access when initially writing to a file.
	int fileNameLength = utf8StringToWideChar(file, -1, NULL);
	wchar_t wcFile[fileNameLength];
	int creation = 0, access = 0;
	HANDLE hFile;

	utf8StringToWideChar(file, -1, wcFile);

	if (strchr(mode, 'w'))
	{
		creation = CREATE_ALWAYS;
		access = GENERIC_WRITE;

		if (strchr(mode, '+'))
			access |= GENERIC_READ;
	}
	else if (strchr(mode, 'r'))
	{
		creation = OPEN_EXISTING;
		access = GENERIC_READ;

		if (strchr(mode, '+'))
			access = GENERIC_WRITE;
	}
	else if (strchr(mode, 'a'))
	{
		creation = OPEN_ALWAYS;
		access = GENERIC_WRITE;

		if (strchr(mode, '+'))
			access |= GENERIC_READ;
	}

	if (creation & GENERIC_WRITE)
	{
		hFile = CreateFileW(wcFile, access, 0, NULL, creation, 0, NULL);

		if (hFile == INVALID_HANDLE_VALUE)
			return NULL;
		else
			CloseHandle(hFile);
	}

	hFile = CreateFileW(wcFile, access, FILE_SHARE_READ, NULL, creation, 0, NULL);

	if (hFile == INVALID_HANDLE_VALUE)
		return NULL;
	else
		return _fdopen(_open_osfhandle((intptr_t)hFile, 0), mode);
#else
	return fopen(file, mode);
#endif
}

int ADM_open(const char *path, int oflag, int aflag)
{
#ifdef __WIN32
	int fileNameLength = utf8StringToWideChar(path, -1, NULL);
	wchar_t wcFile[fileNameLength];
	int creation = 0, access = 0;
	HANDLE hFile;

	utf8StringToWideChar(path, -1, wcFile);

	if (oflag & O_WRONLY || oflag & O_RDWR)
	{
		access = GENERIC_WRITE;

		if (oflag & O_RDWR)
			access |= GENERIC_READ;

		if (oflag & O_CREAT)
		{
			if (oflag & O_EXCL)
				creation = CREATE_NEW;
			else if (oflag & O_TRUNC)
				creation = CREATE_ALWAYS;
			else
				creation = OPEN_ALWAYS;
		}
		else if (oflag & O_TRUNC)
			creation = TRUNCATE_EXISTING;
	}
	else if (oflag & O_RDONLY)
		creation = OPEN_EXISTING;

	if (creation & GENERIC_WRITE)
	{
		hFile = CreateFileW(wcFile, access, 0, NULL, creation, 0, NULL);

		if (hFile == INVALID_HANDLE_VALUE)
			return -1;
		else
			CloseHandle(hFile);
	}

	hFile = CreateFileW(wcFile, access, FILE_SHARE_READ, NULL, creation, 0, NULL);

	if (hFile == INVALID_HANDLE_VALUE)
		return -1;
	else
		return _open_osfhandle((intptr_t)hFile, oflag);
#else
	return open(path, oflag, aflag);
#endif
}

int ADM_fclose(FILE *file)
{
	return fclose(file); 
}

int ADM_unlink(const char *filename)
{
#ifdef __WIN32
	int filenameLength = utf8StringToWideChar(filename, -1, NULL);
	wchar_t wcFilename[filenameLength];

	utf8StringToWideChar(filename, -1, wcFilename);

	return _wunlink(wcFilename);
#else
	return unlink(filename);
#endif
}

int ADM_access(const char *path, int mode)
{
#ifdef __WIN32
	int pathLength = utf8StringToWideChar(path, -1, NULL);
	wchar_t wcPath[pathLength];

	utf8StringToWideChar(path, -1, wcPath);

	return _waccess(wcPath, mode);
#else
	return access(path, mode);
#endif
}

/*
      Get the  directory where jobs are stored
******************************************************/
char *ADM_getCustomDir(void)
{
	if (ADM_customdir)
		return ADM_customdir;

	ADM_customdir = ADM_getHomeRelativePath("custom");

	if (!ADM_mkdir(ADM_customdir))
	{
		printf("can't create custom directory (%s).\n", ADM_customdir);
		return NULL;
	}

	return ADM_customdir;
}

/*
      Get the  directory where jobs are stored
******************************************************/
char *ADM_getJobDir(void)
{
	if (ADM_jobdir)
		return ADM_jobdir;

	ADM_jobdir = ADM_getHomeRelativePath("jobs");

	if (!ADM_mkdir(ADM_jobdir))
	{
		printf("can't create custom directory (%s).\n", ADM_jobdir);
		return NULL;
	}

	return ADM_jobdir;
}

/**
 * 	\fn ADM_getRelativePath
 */
static char *ADM_getRelativePath(const char *base0,const char *base1, const char *base2,const char *base3)
{
	char *result;
	int length = strlen(base1);

	if (base2)
		length += strlen(base2);

	if (base3)
		length += strlen(base3);

	length += strlen(base0);
	length += 5; // Slashes + end 0
	result = (char *)new char [length];
	strcpy(result, base0);
	strcat(result, separator);
	strcat(result, base1);

	if (strlen(base1))
		strcat(result, separator);

	if (base2)
	{
		strcat(result, base2);
		strcat(result, separator);

		if (base3)
		{
			strcat(result, base3);
			strcat(result, separator);
		}
	}

	return result;
}

/**
 * 	\fn char *ADM_getHomeRelativePath(const char *base1, const char *base2=NULL,const char *base3=NULL);
 *  \brief Returns home directory +base 1 + base 2... The return value is a copy, and must be deleted []
 */
char *ADM_getHomeRelativePath(const char *base1, const char *base2,const char *base3)
{
	return ADM_getRelativePath(ADM_getBaseDir(), base1, base2, base3);
}

char *ADM_getInstallRelativePath(const char *base1, const char *base2,const char *base3)
{
#ifdef __WIN32
	wchar_t wcModuleName[MAX_PATH];

	GetModuleFileNameW(0, wcModuleName, sizeof(wcModuleName) / sizeof(wchar_t));

	int len = wideCharStringToUtf8(wcModuleName, -1, NULL);
	char moduleName[len];

	wideCharStringToUtf8(wcModuleName, -1, moduleName);

	char *slash = strrchr(moduleName, '\\');
		
	if (slash)
		*slash = '\0';

	return ADM_getRelativePath(moduleName, base1, base2, base3);
#elif defined(__APPLE__)
#define MAX_PATH_SIZE 1024

	char buffer[MAX_PATH_SIZE];

	CFURLRef url(CFBundleCopyExecutableURL(CFBundleGetMainBundle()));
	buffer[0] = '\0';

	if (url)
	{
		CFURLGetFileSystemRepresentation(url, true, (UInt8*)buffer, MAX_PATH_SIZE);
		CFRelease(url);

		char *slash = strrchr(buffer, '/');
		
		if (slash)
			*slash = '\0';
	}

	return ADM_getRelativePath(buffer, base1, base2, base3);
#else
	return ADM_getRelativePath(ADM_INSTALL_DIR, base1, base2, base3);
#endif
}

char *ADM_getPluginPath(void)
{
#ifdef _WIN32
	const char *startDir="";
	const char *pluginDir="plugins";
#else
	const char *pluginDir="ADM_plugins";

#ifdef __APPLE__
    const char *startDir="../Libraries/lib";
#else
    const char *startDir="lib";
#endif
#endif

	return ADM_getInstallRelativePath(startDir, pluginDir, "videoEncoder");
}

char *ADM_getScriptPath(void)
{
#ifdef _WIN32
	const char *startDir = "";
	const char *scriptPath = "scripts";
#else
	const char *startDir = "share";
	const char *scriptPath = "ADM_scripts";
#endif

	return ADM_getInstallRelativePath(startDir, scriptPath, NULL);
}

/*
      Get the root directory for .avidemux stuff
******************************************************/
char *ADM_getBaseDir(void)
{
	char *home;

	if (baseDirDone)
		return ADM_basedir;

	// Get the base directory
#ifdef __WIN32
	wchar_t wcHome[MAX_PATH];

	if (SHGetFolderPathW(NULL, CSIDL_APPDATA, NULL, 0, wcHome) == S_OK)
	{
		int len = wideCharStringToUtf8(wcHome, -1, NULL);
		home = new char[len];

		wideCharStringToUtf8(wcHome, -1, home);
	}
	else
	{
		printf("Oops: can't determine the Application Data folder.");
		home = ADM_strdup("c:\\");
	}
#else
	const char* homeEnv = getenv("HOME");

	if (homeEnv)
	{
		home = new char[strlen(homeEnv) + 1];
		strcpy(home, homeEnv);
	}
	else
	{
		printf("Oops: can't determine $HOME.");

		return NULL;
	}
#endif

	// Try to open the .avidemux directory
	char *dirname = new char[strlen(home) + strlen(ADM_DIR_NAME) + 2];
	strcpy(dirname, home);
	strcat(dirname, ADM_DIR_NAME);

	if (!ADM_mkdir(dirname))
	{
		printf("Oops: cannot create the .avidemux directory", NULL);
		delete [] dirname;
		return NULL;
	}

	delete [] dirname;

	// Now built the filename
	strncpy(ADM_basedir,home, 1023);
	strncat(ADM_basedir, ADM_DIR_NAME, 1023 - strlen(ADM_basedir));
	baseDirDone = 1;
	printf("Using %s as base directory for prefs/jobs/...\n", ADM_basedir);

	return ADM_basedir;
}

#ifdef __WIN32
#define DIR _WDIR
#define dirent _wdirent
#define opendir _wopendir
#define readdir _wreaddir
#define closedir _wclosedir
#endif

/*----------------------------------------
      Create a directory
      If it already exists, do nothing
------------------------------------------*/
uint8_t ADM_mkdir(const char *dirname)
{
	DIR *dir = NULL;

#ifdef __WIN32
	int dirNameLength = utf8StringToWideChar(dirname, -1, NULL);
	wchar_t dirname2[dirNameLength];

	utf8StringToWideChar(dirname, -1, dirname2);
#else
	const char* dirname2 = dirname;
#endif

	// Check it already exists ?
	dir = opendir(dirname2);

	if (dir)
	{ 
		printf("Directory %s exists.Good.\n", dirname);
		closedir(dir);
		return 1;
	}
#ifdef __WIN32
	if (_wmkdir(dirname2))
	{
		printf("Oops: mkdir failed on %s\n", dirname);
		return 0;
	}
#else
	char *sys = new char[strlen(dirname2) + strlen("mkdir ") + 2];

	strcpy(sys, "mkdir ");
	strcat(sys, dirname2);
	printf("Creating dir :%s\n", sys);
	system(sys);

	delete [] sys;
#endif

	if ((dir = opendir(dirname2)) == NULL)
		return 0;

	closedir(dir);

	return 1;
}
/**
 *  \fn buildDirectoryContent
 * 	\brief Returns the content of a dir with the extension ext. The receiving array must be allocated by caller
 * (just the array, not the names themselves)
 */
uint8_t buildDirectoryContent(uint32_t *outnb, const char *base, char *jobName[], int maxElems, const char *ext)
{
	DIR *dir;
	struct dirent *direntry;
	int dirmax = 0, len;
	int extlen = strlen(ext);

	ADM_assert(extlen);

#ifdef __WIN32
	int dirNameLength = utf8StringToWideChar(base, -1, NULL);
	wchar_t base2[dirNameLength];

	utf8StringToWideChar(base, -1, base2);
#else
	const char *base2 = base;
#endif

	dir = opendir(base2);
	if (!dir)
		return 0;

	while (direntry = readdir(dir))
	{
#ifdef __WIN32
		int dirLength = wideCharStringToUtf8(direntry->d_name, -1, NULL);
		char d_name[dirLength];

		wideCharStringToUtf8(direntry->d_name, -1, d_name);
#else
		const char *d_name = direntry->d_name;
#endif

		len = strlen(d_name);

		if (len < (extlen + 1))
			continue;

		int xbase = len - extlen;

		if (memcmp(d_name + xbase, ext, extlen))
			//if (direntry->d_name[len-1]!='s' || direntry->d_name[len-2]!='j' || direntry->d_name[len-3]!='.')
		{
			printf("ignored: %s\n", d_name);
			continue;
		}

		jobName[dirmax] = (char *)ADM_alloc(strlen(base) + strlen(d_name) + 2);
		strcpy(jobName[dirmax], base);
		strcat(jobName[dirmax], "/");
		strcat(jobName[dirmax], d_name);
		dirmax++;

		if (dirmax >= maxElems)
		{
			printf("[jobs]: Max # of jobs exceeded\n");
			break;
		}
	}

	closedir(dir);
	*outnb = dirmax;

	return 1;
}
//------------------------------------------------------------------

/*

** note: it modifies it's first argument
*/
void simplify_path(char **buf)
{
	unsigned int last1slash = 0;
	unsigned int last2slash = 0;

	while (!strncmp(*buf, "/../", 4))
		memmove(*buf, *buf + 3, strlen(*buf + 3) + 1);

	for (unsigned int i = 0; i < strlen(*buf) - 2; i++)
		while (!strncmp(*buf + i, "/./", 3))
			memmove(*buf + i, *buf + i + 2, strlen(*buf + i + 2) + 1);

	for (unsigned int i = 0; i < strlen(*buf) - 3; i++)
	{
		if (*(*buf + i) == '/')
		{
			last2slash = last1slash;
			last1slash = i;
		}

		if (!strncmp(*buf + i, "/../", 4))
		{
			memmove(*buf + last2slash, *buf + i + 3, strlen(*buf + i + 3) + 1);

			return simplify_path(buf);
		}
	}
}

/**
        \fn ADM_PathCanonize
        \brief Canonize the path, returns a copy of the absolute path given as parameter
*/
char *ADM_PathCanonize(const char *tmpname)
{
	char path[300];
	char *out;

	if (!getcwd(path, 300))
	{
		fprintf(stderr, "\ngetcwd() failed with: %s (%u)\n", strerror(errno), errno);
		path[0] = '\0';
	}

	if (!tmpname || tmpname[0] == 0)
	{
		out = new char[strlen(path) + 2];
		strcpy(out, path);
#ifndef __WIN32
		strcat(out, "/");
#else
		strcat(out, "\\");
#endif
		printf("\n Canonizing null string ??? (%s)\n", out);
	}
	else if (tmpname[0] == '/'
#if defined(__WIN32)
		|| tmpname[1] == ':'
#endif
		)
	{
		out = new char[strlen(tmpname) + 1];
		strcpy(out, tmpname);

		return out;
	}
	else
	{
		out = new char[strlen(path) + strlen(tmpname) + 6];
		strcpy(out, path);
#ifndef __WIN32
		strcat(out, "/");
#else
		strcat(out, "\\");
#endif
		strcat(out, tmpname);
	}

	simplify_path(&out);

	return out;
}

/**
        \fn ADM_PathStripName
	\brief Returns path only /foo/bar.avi -> /foo INPLACE, no copy done

*/
void ADM_PathStripName(char *str)
{
	int len = strlen(str);

	if (len <= 1)
		return;

	len--;

#ifndef __WIN32
	while (*(str + len) != '/' && len)
#else
	while (*(str + len) != '\\' && len)
#endif
	{
		*(str + len) = 0;
		len--;
	}
}

/**
    \fn ADM_GetFileName
    \brief Get the filename without path. /foo/bar.avi -> bar.avi INPLACE, NO COPY

*/
const char *ADM_GetFileName(const char *str)
{
	const char *filename;
	const char *filename2;

#ifndef __WIN32
	filename = strrchr(str, '/');
#else
	filename = strrchr(str, '\\');
	filename2 = strrchr(str, '/');

	if (filename2 && filename)
		if (filename2 > filename)
			filename = filename2;
#endif

	if (filename)
		return filename + 1;
	else
		return str;
}

/**
    \fn ADM_PathSplit
    \brief Split path into absolute path+name and extention i.e. /foo/bar/zee.avi -> /foo/bar/zee,avi.             Copy are returned

*/
void ADM_PathSplit(const char *str, char **root, char **ext)
{
	char *full;
	uint32_t l;

	full = ADM_PathCanonize(str);
	// Search the last
	l = strlen(full);
	l--;
	ADM_assert(l > 0);

	while (*(full + l) != '.' && l)
		l--;

	if (!l || l == (strlen(full) - 1))
	{
		if (l == (strlen(full) - 1))
			*(full + l) = 0;  // remove trailing

		*ext = new char[2];
		*root = full;
		strcpy(*ext, "");

		return;
	}
	// else we do get an extension
	// starting at l+1
	uint32_t suff;

	suff = strlen(full) - l - 1;
	*ext = new char[suff + 1];
	strcpy(*ext, full + l + 1);
	*(full + l) = 0;
	*root = full;
}

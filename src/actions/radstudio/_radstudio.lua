--
-- _radstudio.lua
-- Define the RAD Studio 2010-XE3 ,10.x, 11 actions.
-- Copyright (c) 2008-2022 Jason Perkins and the Premake project
--

--TODO
-- * Support "Native" platform
-- * Support vpath
-- * Fix fails to save groupproj(?) when location is specified.


	premake.radstudio = { }
	local radstudio = premake.radstudio

	premake.radstudio.rs2010 = { }
	premake.radstudio.rsxe = { }
	premake.radstudio.rsxe2 = { }
	premake.radstudio.rsxe3 = { }
	premake.radstudio.rs100 = { }  -- 10 Seattle
	premake.radstudio.rs101 = { }  -- 10.1 Berlin
	premake.radstudio.rs102 = { }  -- 10.2 Tokyo
	premake.radstudio.rs103 = { }  -- 10.3 Rio
	premake.radstudio.rs104 = { }  -- 10.4 Sydney
	premake.radstudio.rs110 = { }  -- 11 Alexandria
	premake.radstudio.rs120 = { }  -- 12 Athens

--
-- Map Premake platform identifiers to the RAD Studio versions.
--
	radstudio.platforms = { 
		Native  = "Win32",
		_Base   = "Base",		-- used for base config
		x32     = "Win32", 
		x64     = "Win64",
		Universal32	= "OSX32",
		Universal64	= "OSX64",
	}

	radstudio.rs2010.platforms = { 
		Native  = "Win32",
		_Base   = "Base",		-- used for base config
		x32     = "Win32", 
	}

	radstudio.rsxe.platforms = { 
		Native  = "Win32",
		_Base   = "Base",		-- used for base config
		x32     = "Win32", 
	}
	
	radstudio.rsxe2.platforms = { 
		Native  = "Win32",
		_Base   = "Base",		-- used for base config
		x32     = "Win32", 
--		x64     = "Win64",		-- C++ Builder doesn't support x64
		Universal32	= "OSX32",
		Universal64	= "OSX64",
	}

	radstudio.rsxe3.platforms = { 
		Native  = "Win32",
		_Base   = "Base",		-- used for base config
		x32     = "Win32", 
		x64     = "Win64",
		Universal32	= "OSX32",
		Universal64	= "OSX64",
	}

	radstudio.rs100.platforms = { 
		Native  = "Win32",
		_Base   = "Base",		-- used for base config
		x32     = "Win32", 
		x64     = "Win64",
		Universal32	= "OSX32",
		Universal64	= "OSX64",
	}

	radstudio.rs101.platforms = { 
		Native  = "Win32",
		_Base   = "Base",		-- used for base config
		x32     = "Win32", 
		x64     = "Win64",
		Universal32	= "OSX32",
		Universal64	= "OSX64",
	}

	radstudio.rs102.platforms = { 
		Native  = "Win32",
		_Base   = "Base",		-- used for base config
		x32     = "Win32", 
		x64     = "Win64",
		Universal32	= "OSX32",
		Universal64	= "OSX64",
	}

	radstudio.rs103.platforms = { 
		Native  = "Win32",
		_Base   = "Base",		-- used for base config
		x32     = "Win32", 
		x64     = "Win64",
		Universal32	= "OSX32",
		Universal64	= "OSX64",
	}

	radstudio.rs104.platforms = { 
		Native  = "Win32",
		_Base   = "Base",		-- used for base config
		x32     = "Win32", 
		x64     = "Win64",
		Universal32	= "OSX32",
		Universal64	= "OSX64",
	}

	radstudio.rs110.platforms = { 
		Native  = "Win32",
		_Base   = "Base",		-- used for base config
		x32     = "Win32", 
		x64     = "Win64",
		Universal32	= "OSX32",
		Universal64	= "OSX64",
	}

	radstudio.rs120.platforms = {
		Native  = "Win32",
		_Base   = "Base",		-- used for base config
		x32     = "Win32",
		x64     = "Win64",
		Universal32	= "OSX32",
		Universal64	= "OSX64",
	}

	-- map from premake's kind to RadStudio's AppType
	radstudio.app_types = {
		ConsoleApp = "Console",
		WindowedApp = "Application",
		StaticLib = "StaticLibrary",
		SharedLib = "Library",
	}
	
	-- 
	radstudio.frameworks = {
		vcl = "VCL",
		fmx = "FMX",
	}

--
-- Clean RAD Studio files
--

	function radstudio.cleansolution(sln)
		premake.clean.file(sln, "%%.groupproj")
		premake.clean.file(sln, "%%.groupproj.local")
	end
	
	function radstudio.cleanproject(prj)
		local fname = premake.project.getfilename(prj, "%%")
		os.remove(fname .. ".cbproj")
		os.remove(fname .. ".cbproj.local")
	end

	function radstudio.cleantarget(name)
		os.remove(name .. ".exe.manifest")
	end

--
-- Register RAD Studio 2010
--

	newaction 
	{
		trigger         = "rs2010",
		shortname       = "RAD Studio 2010",
		description     = "Generate Embarcadero RAD Studio 2010 project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++" },
		
		valid_tools     = {
			cc     = { "bcc" },
		},

		onsolution = function(sln)
			premake.generate(sln, "%%.groupproj", radstudio.gproj2010.generate)
		end,
		
		onproject = function(prj)
			premake.generate(prj, "%%.cbproj", premake.radstudio.rs2010x.generate)
		end,
		
		oncleansolution = premake.radstudio.cleansolution,
		oncleanproject  = premake.radstudio.cleanproject,
		oncleantarget   = premake.radstudio.cleantarget
	}
	
--
-- Register RAD Studio XE
--

	newaction 
	{
		trigger         = "rsxe",
		shortname       = "RAD Studio XE",
		description     = "Generate Embarcadero RAD Studio XE project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++" },
		
		valid_tools     = {
			cc     = { "bcc" },
		},

		onsolution = function(sln)
			premake.generate(sln, "%%.groupproj", radstudio.gproj2010.generate)
		end,
		
		onproject = function(prj)
			premake.generate(prj, "%%.cbproj", premake.radstudio.rs2010x.generate)
		end,
		
		oncleansolution = premake.radstudio.cleansolution,
		oncleanproject  = premake.radstudio.cleanproject,
		oncleantarget   = premake.radstudio.cleantarget
	}
	
--
-- Register RAD Studio XE2
--

	newaction 
	{
		trigger         = "rsxe2",
		shortname       = "RAD Studio XE2",
		description     = "Generate Embarcadero RAD Studio XE2 project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++" },
		
		valid_tools     = {
			cc     = { "bcc" },
		},

		onsolution = function(sln)
			premake.generate(sln, "%%.groupproj", radstudio.gproj2010.generate)
		end,
		
		onproject = function(prj)
			premake.generate(prj, "%%.cbproj", premake.radstudio.rs2010x.generate)
		end,
		
		oncleansolution = premake.radstudio.cleansolution,
		oncleanproject  = premake.radstudio.cleanproject,
		oncleantarget   = premake.radstudio.cleantarget
	}
	
--
-- Register RAD Studio XE3
--

	newaction 
	{
		trigger         = "rsxe3",
		shortname       = "RAD Studio XE3",
		description     = "Generate Embarcadero RAD Studio XE3 project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++" },
		
		valid_tools     = {
			cc     = { "bcc" },
		},

		onsolution = function(sln)
			premake.generate(sln, "%%.groupproj", radstudio.gproj2010.generate)
		end,
		
		onproject = function(prj)
			premake.generate(prj, "%%.cbproj", premake.radstudio.rs2010x.generate)
		end,
		
		oncleansolution = premake.radstudio.cleansolution,
		oncleanproject  = premake.radstudio.cleanproject,
		oncleantarget   = premake.radstudio.cleantarget
	}
	
--
-- Register RAD Studio 10 Seattle
--

	newaction
	{
		trigger         = "rs100",
		shortname       = "RAD Studio 10 Seattle",
		description     = "Generate Embarcadero RAD Studio 10 Seattle project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },

		valid_languages = { "C", "C++" },

		valid_tools     = {
			cc     = { "bcc" },
		},

		onsolution = function(sln)
			premake.generate(sln, "%%.groupproj", radstudio.gproj2010.generate)
		end,

		onproject = function(prj)
			premake.generate(prj, "%%.cbproj", premake.radstudio.rs2010x.generate)
		end,

		oncleansolution = premake.radstudio.cleansolution,
		oncleanproject  = premake.radstudio.cleanproject,
		oncleantarget   = premake.radstudio.cleantarget
	}

--
-- Register RAD Studio 10.1 Berlin
--

	newaction
	{
		trigger         = "rs101",
		shortname       = "RAD Studio 10.1 Berlin",
		description     = "Generate Embarcadero RAD Studio 10.1 Berlin project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },

		valid_languages = { "C", "C++" },

		valid_tools     = {
			cc     = { "bcc" },
		},

		onsolution = function(sln)
			premake.generate(sln, "%%.groupproj", radstudio.gproj2010.generate)
		end,

		onproject = function(prj)
			premake.generate(prj, "%%.cbproj", premake.radstudio.rs2010x.generate)
		end,

		oncleansolution = premake.radstudio.cleansolution,
		oncleanproject  = premake.radstudio.cleanproject,
		oncleantarget   = premake.radstudio.cleantarget
	}

--
-- Register RAD Studio 10.2 Tokyo
--

	newaction
	{
		trigger         = "rs102",
		shortname       = "RAD Studio 10.2 Tokyo",
		description     = "Generate Embarcadero RAD Studio 10.2 Tokyo project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },

		valid_languages = { "C", "C++" },

		valid_tools     = {
			cc     = { "bcc" },
		},

		onsolution = function(sln)
			premake.generate(sln, "%%.groupproj", radstudio.gproj2010.generate)
		end,

		onproject = function(prj)
			premake.generate(prj, "%%.cbproj", premake.radstudio.rs2010x.generate)
		end,

		oncleansolution = premake.radstudio.cleansolution,
		oncleanproject  = premake.radstudio.cleanproject,
		oncleantarget   = premake.radstudio.cleantarget
	}

--
-- Register RAD Studio 10.3 Rio
--

	newaction
	{
		trigger         = "rs103",
		shortname       = "RAD Studio 10.3 Rio",
		description     = "Generate Embarcadero RAD Studio 10.3 Rio project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },

		valid_languages = { "C", "C++" },

		valid_tools     = {
			cc     = { "bcc" },
		},

		onsolution = function(sln)
			premake.generate(sln, "%%.groupproj", radstudio.gproj2010.generate)
		end,

		onproject = function(prj)
			premake.generate(prj, "%%.cbproj", premake.radstudio.rs2010x.generate)
		end,

		oncleansolution = premake.radstudio.cleansolution,
		oncleanproject  = premake.radstudio.cleanproject,
		oncleantarget   = premake.radstudio.cleantarget
	}

--
-- Register RAD Studio 10.4 Sydney
--

	newaction
	{
		trigger         = "rs104",
		shortname       = "RAD Studio 10.4 Sydney",
		description     = "Generate Embarcadero RAD Studio 10.4 Sydney project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },

		valid_languages = { "C", "C++" },

		valid_tools     = {
			cc     = { "bcc" },
		},

		onsolution = function(sln)
			premake.generate(sln, "%%.groupproj", radstudio.gproj2010.generate)
		end,

		onproject = function(prj)
			premake.generate(prj, "%%.cbproj", premake.radstudio.rs2010x.generate)
		end,

		oncleansolution = premake.radstudio.cleansolution,
		oncleanproject  = premake.radstudio.cleanproject,
		oncleantarget   = premake.radstudio.cleantarget
	}

--
-- Register RAD Studio 11 Alexandria
--

	newaction
	{
		trigger         = "rs110",
		shortname       = "RAD Studio 11 Alexandria",
		description     = "Generate Embarcadero RAD Studio 11 Alexandria project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },

		valid_languages = { "C", "C++" },

		valid_tools     = {
			cc     = { "bcc" },
		},

		onsolution = function(sln)
			premake.generate(sln, "%%.groupproj", radstudio.gproj2010.generate)
		end,

		onproject = function(prj)
			premake.generate(prj, "%%.cbproj", premake.radstudio.rs2010x.generate)
		end,

		oncleansolution = premake.radstudio.cleansolution,
		oncleanproject  = premake.radstudio.cleanproject,
		oncleantarget   = premake.radstudio.cleantarget
	}

--
-- Register RAD Studio 12 Athens
--

newaction
{
	trigger         = "rs120",
	shortname       = "RAD Studio 12 Athens",
	description     = "Generate Embarcadero RAD Studio 12 Athens project files",
	os              = "windows",

	valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },

	valid_languages = { "C", "C++" },

	valid_tools     = {
		cc     = { "bcc" },
	},

	onsolution = function(sln)
		premake.generate(sln, "%%.groupproj", radstudio.gproj2010.generate)
	end,

	onproject = function(prj)
		premake.generate(prj, "%%.cbproj", premake.radstudio.rs2010x.generate)
	end,

	oncleansolution = premake.radstudio.cleansolution,
	oncleanproject  = premake.radstudio.cleanproject,
	oncleantarget   = premake.radstudio.cleantarget
}

--
-- Assemble the project file name.
--

	function radstudio.projectfile(prj)
		local extension
		extension = ".cbproj"
		local fname = path.join(prj.location, prj.name)
		return fname..extension
	end

--
--
--

function radstudio.write_utf8_bom()
	local prev_eol = io.eol
	io.eol = ''
	_p('\239\187\191')
	io.eol = prev_eol
end


-- http://stackoverflow.com/questions/1410862/concatenation-of-tables-in-lua
function array_concat(...)
    local t = {}

    for i = 1, arg.n do
        local array = arg[i]
        if (type(array) == "table") then
            for j = 1, #array do
                t[#t+1] = array[j]
            end
        else
            t[#t+1] = array
        end
    end

    return t
end

function radstudio.rstudio_configs()
	return array_concat('Base', configurations())
end

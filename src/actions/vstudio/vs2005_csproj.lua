--
-- vs2005_csproj.lua
-- Generate a Visual Studio 2005/2008 C# project.
-- Copyright (c) 2009-2011 Jason Perkins and the Premake project
--

--
-- Set up namespaces
--

	premake.vstudio.cs2005 = { }
	local vstudio = premake.vstudio
	local cs2005  = premake.vstudio.cs2005


--
-- Figure out what elements a particular source code file need in its item
-- block, based on its build action and any related files in the project.
--

	local function getelements(prj, action, fname)

		if action == "Compile" and fname:endswith(".cs") then
			if fname:endswith(".Designer.cs") then
				-- is there a matching *.cs file?
				local basename = fname:sub(1, -13)
				local testname = basename .. ".cs"
				if premake.findfile(prj, testname) then
					return "Dependency", testname
				end
				-- is there a matching *.resx file?
				testname = basename .. ".resx"
				if premake.findfile(prj, testname) then
					return "AutoGen", testname
				end
			elseif fname:endswith(".xaml.cs") then
				-- is there a matching *.cs file?
				local basename = fname:sub(1, -9)
				local testname = basename .. ".xaml"
				if premake.findfile(prj, testname) then
					return "SubTypeCode", path.getname(testname)
				end       
			else
				-- is there a *.Designer.cs file?
				local basename = fname:sub(1, -4)
				local testname = basename .. ".Designer.cs"
				if premake.findfile(prj, testname) then
					return "SubTypeForm"
				end
			end
		end

		if action == "EmbeddedResource" and fname:endswith(".resx") then
			-- is there a matching *.cs file?
			local basename = fname:sub(1, -6)
			local testname = path.getname(basename .. ".cs")
			if premake.findfile(prj, testname) then
				if premake.findfile(prj, basename .. ".Designer.cs") then
					return "DesignerType", testname
				else
					return "Dependency", testname
				end
			else
				-- is there a matching *.Designer.cs?
				testname = path.getname(basename .. ".Designer.cs")
				if premake.findfile(prj, testname) then
					return "AutoGenerated"
				end
			end
		end
		
		if fname:endswith(".xaml") then
			return "XamlDesigner"
		end

		if action == "Content" then
			return "CopyNewest"
		end

		return "None"
	end


--
-- Return the Visual Studio architecture identification string. The logic
-- to select this is getting more complicated in VS2010, but I haven't
-- tackled all the permutations yet.
--

	function cs2005.arch(prj)
		return "AnyCPU"
	end


--
-- Write out the <Files> element.
--

	function cs2005.files(prj)
		local tr = premake.project.buildsourcetree(prj)
		premake.tree.traverse(tr, {
			onleaf = function(node)
				local action = premake.dotnet.getbuildaction(node.cfg)
				local fname  = path.translate(premake.esc(node.cfg.name), "\\")
				local elements, dependency = getelements(prj, action, node.path)

				if elements == "None" then
					_p('    <%s Include="%s" />', action, fname)
				else
					_p('    <%s Include="%s">', action, fname)
					if elements == "AutoGen" then
						_p('      <AutoGen>True</AutoGen>')
					elseif elements == "AutoGenerated" then
						_p('      <SubType>Designer</SubType>')
						_p('      <Generator>ResXFileCodeGenerator</Generator>')
						_p('      <LastGenOutput>%s.Designer.cs</LastGenOutput>', premake.esc(path.getbasename(node.name)))
					elseif elements == "SubTypeDesigner" then
						_p('      <SubType>Designer</SubType>')
					elseif elements == "SubTypeForm" then
						_p('      <SubType>Form</SubType>')
					elseif elements == "SubTypeCode" then
						_p('      <SubType>Code</SubType>')
					elseif elements == "XamlDesigner" then
						_p('      <SubType>Designer</SubType>')
						_p('      <Generator>MSBuild:Compile</Generator>')
					elseif elements == "PreserveNewest" then
						_p('      <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>')
					end
					if dependency then
						_p('      <DependentUpon>%s</DependentUpon>', path.translate(premake.esc(dependency), "\\"))
					end
					_p('    </%s>', action)
				end
			end
		}, false)
	end


--
-- Write the opening <Project> element.
--

	function cs2005.projectelement(prj)
		local action = premake.action.current()

		local toolversion = ''
		if action.vstudio.toolsVersion then
			toolversion = string.format(' ToolsVersion="%s"', action.vstudio.toolsVersion)
		end

		if _ACTION > "vs2008" then
			_p('<?xml version="1.0" encoding="utf-8"?>')
		end
		_p('<Project%s DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">', toolversion)
	end


--
-- Write the opening PropertyGroup, which contains the project-level settings.
--

	function cs2005.projectsettings(prj)
		_p('  <PropertyGroup>')
		_p('    <Configuration Condition=" \'$(Configuration)\' == \'\' ">%s</Configuration>', premake.esc(prj.solution.configurations[1]))
		_p('    <Platform Condition=" \'$(Platform)\' == \'\' ">%s</Platform>', cs2005.arch(prj))

		local action = premake.action.current()
		if action.vstudio.productVersion then
			_p('    <ProductVersion>%s</ProductVersion>', action.vstudio.productVersion)
		end

		if _ACTION < "vs2012" then
			_p('    <SchemaVersion>2.0</SchemaVersion>')
		end

		_p('    <ProjectGuid>{%s}</ProjectGuid>', prj.uuid)
		_p('    <OutputType>%s</OutputType>', premake.dotnet.getkind(prj))
		_p('    <AppDesignerFolder>Properties</AppDesignerFolder>')
		_p('    <RootNamespace>%s</RootNamespace>', prj.buildtarget.basename)
		_p('    <AssemblyName>%s</AssemblyName>', prj.buildtarget.basename)

		local framework = prj.framework or action.vstudio.targetFramework
		if framework then
			_p('    <TargetFrameworkVersion>v%s</TargetFrameworkVersion>', framework)
		end

		if _ACTION == 'vs2010' then
			_p('    <TargetFrameworkProfile></TargetFrameworkProfile>')
		end

		if _ACTION >= "vs2010" then
			_p('    <FileAlignment>512</FileAlignment>')
		end

		_p('  </PropertyGroup>')
	end


--
-- Write the PropertyGroup element for a specific configuration block.
--

	function cs2005.propertygroup(cfg)
		_p('  <PropertyGroup Condition=" \'$(Configuration)|$(Platform)\' == \'%s|%s\' ">', premake.esc(cfg.name), cs2005.arch(cfg))
		if _ACTION > "vs2008" then
			_p('    <PlatformTarget>%s</PlatformTarget>', cs2005.arch(cfg))
		end
	end

--
-- Write the build events groups.
--

	function cs2005.buildevents(cfg)
		if #cfg.prebuildcommands > 0 then
			_p('  <PropertyGroup>')
			_p('    <PreBuildEvent>%s</PreBuildEvent>', premake.esc(table.implode(cfg.prebuildcommands, "", "", "\r\n")))
			_p('  </PropertyGroup>')
		end
		if #cfg.postbuildcommands > 0 then
			_p('  <PropertyGroup>')
			_p('    <PostBuildEvent>%s</PostBuildEvent>', premake.esc(table.implode(cfg.postbuildcommands, "", "", "\r\n")))
			_p('  </PropertyGroup>')
		end
	end


--
-- The main function: write the project file.
--

	function cs2005.generate(prj)
		io.eol = "\r\n"

		cs2005.projectelement(prj)

		if _ACTION > "vs2010" then
			_p('  <Import Project="$(MSBuildExtensionsPath)\\$(MSBuildToolsVersion)\\Microsoft.Common.props" Condition="Exists(\'$(MSBuildExtensionsPath)\\$(MSBuildToolsVersion)\\Microsoft.Common.props\')" />')
		end

		cs2005.projectsettings(prj)

		for cfg in premake.eachconfig(prj) do
			cs2005.propertygroup(cfg)

			if cfg.flags.Symbols then
				_p('    <DebugSymbols>true</DebugSymbols>')
				_p('    <DebugType>full</DebugType>')
			else
				_p('    <DebugType>pdbonly</DebugType>')
			end
			_p('    <Optimize>%s</Optimize>', iif(cfg.flags.Optimize or cfg.flags.OptimizeSize or cfg.flags.OptimizeSpeed, "true", "false"))
			_p('    <OutputPath>%s</OutputPath>', cfg.buildtarget.directory)
			_p('    <DefineConstants>%s</DefineConstants>', table.concat(premake.esc(cfg.defines), ";"))
			_p('    <ErrorReport>prompt</ErrorReport>')
			_p('    <WarningLevel>4</WarningLevel>')
			if cfg.flags.Unsafe then
				_p('    <AllowUnsafeBlocks>true</AllowUnsafeBlocks>')
			end
			if cfg.flags.FatalWarnings then
				_p('    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>')
			end
			_p('  </PropertyGroup>')
		end

		_p('  <ItemGroup>')
		for _, ref in ipairs(premake.getlinks(prj, "siblings", "object")) do
			_p('    <ProjectReference Include="%s">', path.translate(path.getrelative(prj.location, vstudio.projectfile(ref)), "\\"))
			_p('      <Project>{%s}</Project>', ref.uuid)
			_p('      <Name>%s</Name>', premake.esc(ref.name))
			_p('    </ProjectReference>')
		end
		for _, linkname in ipairs(premake.getlinks(prj, "system", "name")) do
			_p('    <Reference Include="%s" />', premake.esc(linkname))
		end
		_p('  </ItemGroup>')

		_p('  <ItemGroup>')
		cs2005.files(prj)
		_p('  </ItemGroup>')

		local msbuild = iif(_ACTION < "vs2012", "Bin", "Tools")
		_p('  <Import Project="$(MSBuild%sPath)\\Microsoft.CSharp.targets" />', msbuild)

		-- build events
		cs2005.buildevents(prj)

		_p('  <!-- To modify your build process, add your task inside one of the targets below and uncomment it.')
		_p('       Other similar extension points exist, see Microsoft.Common.targets.')
		_p('  <Target Name="BeforeBuild">')
		_p('  </Target>')
		_p('  <Target Name="AfterBuild">')
		_p('  </Target>')
		_p('  -->')
		_p('</Project>')

	end


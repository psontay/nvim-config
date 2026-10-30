-- Java / Spring Boot — bổ sung cho extra lazyvim.plugins.extras.lang.java (nvim-jdtls)
return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      local java = require("custom.java")

      -- jdtls cần JDK >= 21 để chạy; JDK của project có thể khác (khai báo ở runtimes bên dưới)
      local cmd = { vim.fn.exepath("jdtls") }
      local launcher = java.launcher_home()
      if launcher then
        table.insert(cmd, "--java-executable=" .. launcher .. "/bin/java")
      end
      local lombok = vim.fn.expand("$MASON/share/jdtls/lombok.jar")
      if vim.uv.fs_stat(lombok) then
        table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok)
      end
      opts.cmd = cmd

      -- Một jdtls cho cả project nhiều module (không khởi động JVM riêng cho từng module)
      opts.root_dir = java.root_dir
      -- Mỗi đường dẫn project có workspace riêng: ~/.cache/nvim/jdtls/<tên>-<hash>/
      opts.project_name = java.project_name

      -- LazyVim nạp mọi *.jar của java-test làm bundle; 2 jar không phải OSGi bundle và các symlink
      -- trùng làm jdtls báo "Failed to load extension bundles" → lọc lại.
      opts.jdtls = function(config)
        local seen, bundles = {}, {}
        for _, jar in ipairs(config.init_options and config.init_options.bundles or {}) do
          local name = vim.fs.basename(jar)
          local real = vim.uv.fs_realpath(jar) or jar
          if
            not seen[real]
            and name ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar"
            and name ~= "jacocoagent.jar"
          then
            seen[real] = true
            bundles[#bundles + 1] = jar
          end
        end
        config.init_options.bundles = bundles

        return config
      end
      -- Không quét main class lúc attach (project lớn chưa import xong → "Could not resolve java
      -- executable"). nvim-jdtls tự tìm main class ngay khi bấm <leader>dc / F9 (dap provider);
      -- :JdtUpdateDebugConfig để quét lại thủ công.
      opts.dap_main = false
      -- Lệnh phía client của VS Code mà jdtls gọi sau khi nạp bundle; Neovim không cần làm gì
      vim.lsp.commands["_java.reloadBundles.command"] = function()
        return {}
      end

      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = {
          configuration = {
            runtimes = java.runtimes(),
            -- pom.xml/build.gradle thay đổi → tự đồng bộ lại classpath
            updateBuildConfiguration = "automatic",
          },
          eclipse = { downloadSources = true },
          maven = { downloadSources = true },
          import = {
            maven = { enabled = true },
            gradle = { enabled = true, wrapper = { enabled = true } },
          },
          -- Mở class trong thư viện không có source → tự decompile
          contentProvider = { preferred = "fernflower" },
          signatureHelp = { enabled = true },
          references = { includeDecompiledSources = true },
          implementationsCodeLens = { enabled = false },
          referencesCodeLens = { enabled = false },
          completion = {
            favoriteStaticMembers = {
              "org.junit.jupiter.api.Assertions.*",
              "org.assertj.core.api.Assertions.*",
              "org.mockito.Mockito.*",
              "org.mockito.ArgumentMatchers.*",
              "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
              "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*",
            },
            importOrder = { "java", "javax", "jakarta", "org", "com", "" },
          },
          -- Không gộp import thành dấu * (giống thiết lập phổ biến trong team Spring)
          sources = {
            organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
          },
          inlayHints = { parameterNames = { enabled = "literals" } },
        },
      })
    end,
  },
}

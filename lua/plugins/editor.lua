-- Soạn thảo & điều hướng
return {
  -- flash.nvim chiếm s/S (gốc: thay ký tự/thay dòng) và đổi hành vi f/t/;/,
  -- → tắt để giữ nguyên motion gốc của Vim. Nhảy nhanh bằng / ? f t * # và count.
  { "folke/flash.nvim", enabled = false },
}

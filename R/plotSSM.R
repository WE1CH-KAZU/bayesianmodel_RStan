plotSSM <- function(
    mcmc_sample,
    time_vec,
    obs_vec = NULL,
    state_name,
    graph_title,
    y_label,
    date_labels = "%Y年%m月"
) {
  # 状態空間モデルを図示する関数
  # 
  # Args:
  #   mcmc_sample : MCMCサンプル
  #   time_vec : 時間軸のベクトル（POSIXct）
  #   obs_vec = NULL : 観測値のベクトル（必要なら入れる,列名はobsが必須）
  #   state_name : 図示する変数名
  #   graph_title : グラフタイトル
  #   y_label : グラフy軸ラベル
  #   date_labels : 日付の書式
  # 
  #   Returns:
  #     ggplot2による生成されたグラフ
  
  
  # 1) 取り出し（state_name は文字列）
  draws <- mcmc_sample[[state_name]]
  if (is.null(draws)) {
    stop(sprintf("state_name='%s' が mcmc_sample に存在しません。", state_name))
  }
  
  # 2) 行列前提のチェック
  if (!is.matrix(draws)) {
    draws <- as.matrix(draws)
  }
  
  # 列数 = 時系列長
  Tlen <- ncol(draws)
  
  # 3) time_vec の長さと整合
  if (length(time_vec) != Tlen) {
    stop(sprintf("time_vec の長さ(%d) と状態列数(%d)が一致しません。", length(time_vec), Tlen))
  }
  
  # 4) 事後分位点（列=時点ごと）
  qmat <- t(apply(
    X = draws,
    MARGIN = 2,
    FUN = quantile,
    probs = c(0.025, 0.5, 0.975),
    na.rm = TRUE
  ))
  
  result_df <- data.frame(
    lower = qmat[, 1],
    fit   = qmat[, 2],
    upper = qmat[, 3]
  )
  
  # 5) 時間軸（型をPOSIXct/DateのどちらでもOKに）
  #    - POSIXct/Date/character/numeric を受け取り可能に
  if (inherits(time_vec, "POSIXct")) {
    result_df$time <- time_vec
    x_scale <- ggplot2::scale_x_datetime(date_labels = date_labels)
  } else if (inherits(time_vec, "Date")) {
    result_df$time <- time_vec
    x_scale <- ggplot2::scale_x_date(date_labels = date_labels)
  } else if (is.character(time_vec)) {
    # 文字列 → POSIXct（時刻なしならDateでも可）
    tmp <- try(as.POSIXct(time_vec), silent = TRUE)
    if (inherits(tmp, "POSIXct")) {
      result_df$time <- tmp
      x_scale <- ggplot2::scale_x_datetime(date_labels = date_labels)
    } else {
      result_df$time <- as.Date(time_vec)
      x_scale <- ggplot2::scale_x_date(date_labels = date_labels)
    }
  } else {
    # 連番等は連続軸で
    result_df$time <- time_vec
    x_scale <- ggplot2::scale_x_continuous(name = "time")
  }
  
  # 6) 観測値
  if (!is.null(obs_vec)) {
    if (length(obs_vec) != Tlen) {
      stop("obs_vec の長さが time/state と一致しません。")
    }
    result_df$obs <- obs_vec
  }
  
  # 7) 図示
  p <- ggplot(result_df, aes(x = time)) +
    geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2) +
    geom_line(aes(y = fit), linewidth = 1) +
    labs(title = graph_title, y = y_label) +
    x_scale +
    theme_minimal()
  
  if (!is.null(obs_vec)) {
    p <- p + geom_point(aes(y = obs), alpha = 0.6, size = 0.9)
  }
  
  return(p)
}

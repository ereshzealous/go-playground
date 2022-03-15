  SELECT
    first(price) AS open,
    last(price) AS close,
    max(price) AS high,
    min(price) AS low,
    mean(price) as average
  FROM ticks
  where time > now() - 2mo
    and time < now() - 1mo
    and product = 'AZMZ/USD'
  GROUP BY time(1d), product
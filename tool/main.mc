include "config-scanner.mc"
include "runner.mc"
include "path.mc"
include "string.mc"

let menu = strJoin "\n" [
  "TBA"
]

let options =
  { benchmarks = ""
  , runtimes = ""
  , iters = 1
  , dryRuns = 1
  }

recursive let parseArgs = lam ops. lam args.
  match args with ["--benchmarks"] ++ args then
    match args with [b] ++ args then
      parseArgs {ops with benchmarks = b} args
    else error "--benchmarks with no argument"

  else match args with ["--runtimes"] ++ args then
    match args with [r] ++ args then
      parseArgs {ops with runtimes = r} args
    else error "--runtimes with no argument"

  else match args with ["--iters"] ++ args then
    match args with [n] ++ args then
      parseArgs {ops with iters = string2int n} args
    else error "--iters with no argument"

  else match args with ["--dry-runs"] ++ args then
    match args with [n] ++ args then
      parseArgs {ops with dryRuns = string2int n} args
    else error "--dry-runs with no argument"

  else match args with [] then ops
  else match args with [a] ++ args then
    error (concat "Unknown argument: " a)
  else never
end

let verifyOptions = lam ops.
  map
    (lam t. if t.0 then () else error t.1)
    [ (pathExists ops.runtimes,
       concat "No such directory: " ops.runtimes)
    , (pathExists ops.benchmarks,
       concat "No such directory: " ops.benchmarks)
    , (gti ops.iters 0,
       "Number of iterations should be larger than 0")
    , (geqi ops.dryRuns 0,
       "Number of dry runs should be at least 0")
    ]

let main = lam.
  let ops = parseArgs options (tail argv) in
  verifyOptions ops;

  let runtimes = findRuntimes ops.runtimes in
  let benchmarks = findBenchmarks ops.benchmarks [] runtimes in

  let rs = runBenchmarks benchmarks runtimes in
  printLn (toCSV rs)

mexpr

main ()
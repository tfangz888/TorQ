\d .dqe

resultstab:([procs:`$();tab:`$()]tablecount:`long$();nullcount:`long$();anomcount:`long$());

init:{
  .lg.o[`init;"searching for servers"];
  .servers.startup[];                                                                                           /- Open connection to discovery
  }

updresultstab:{[proc;col;table;tabinput]                                                                        /- upadate results table with results
  .lg.o[`updresultstab;"Updating results table for ",(string table)," table from proc ",string proc];
  colfix:`$5_string col;                                                                                        /- remove namespace from query name
  ![`.dqe.resultstab;((=;`procs;enlist proc);(=;`tab;enlist table));0b;(enlist colfix)!enlist tabinput]         /- Update query results into table
  }

chkinresults:{[proc;table]                                                                                      /- check if record already exists for proc,table pair
  .lg.o[`chkresults;"Checking if ",(string proc),",",(string table)," is in resultstab"];
  if[not (proc;table) in key resultstab;
    .lg.o[`chkinresults;"adding null row for ",(string table)," table from proc ",string proc];
    colcount:-2+count cols resultstab;                                                                          /- get count of unkeyed columns from results table
    `.dqe.resultstab insert raze(proc;table,colcount#0N)]                                                       /- insert proc,table pair with nulls into other columns
  }

qpostback:{[proc;query;result]
  .lg.o[`qpostback;"Postback sucessful for ",string first proc];
  tab:key result;                                                                                               /- get table names from dictionary
  .dqe.chkinresults[first proc]'[tab];
  .dqe.updresultstab[first proc;query]'[tab;value result];
  }

runquery:{[query;params;rs]
  .lg.o[`runquery;"Starting query run for ",string query];
  if[1<count rs;.lg.e[`runquery"error: can only send query to one remote service, trying to send to ",string count rs];:()];
  if[not rs in exec procname from .servers.SERVERS;.lg.e[`runquery;"error: remote service must be a proctype";:()]];

  h:.dqe.gethandles[(),rs];
  .async.postback[h`w;((value query),params);.dqe.qpostback[h`procname;query]];
  }

\d .

.servers.CONNECTIONS:`ALL                                                                                       /- set to nothing so that is only connects to discovery

.dqe.init[]

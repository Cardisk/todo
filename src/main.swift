// Command line arguments
var args = CommandLine.arguments

// Validating args 
args.removeFirst()
if args.count == 0 { crash("Not enough arguments provided.", .few_args) }
else { print("Called Succesfully!") }

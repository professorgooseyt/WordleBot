
$selection = "play";
$all = "FALSE";

while (@ARGV) {
	$buffer = shift @ARGV;
	if ($buffer eq "--mybot") {$selection = "mybot";}
	if ($buffer eq "--dadbot") {$selection = "dadbot";}
	if ($buffer eq "--all") {$mode = "all";}
	if ($buffer eq "--feedback") {$mode = "feedback";}
}

open(WORDS, "solutions.txt") or die "Could not open solutions file\n";
open(ALLOWED, "guesses.txt") or die "Could not open guesses file\n";

my %allowedHash;
my %wordHash;
my @wordArr;

my @contains;
my @exclude;
my @positions;

$count = 0;

while(<WORDS>){
	$line = $_;
	chomp $line;
	$count++;
	$line = uc($line);
	push(@wordArr, $line);
	$wordHash{$line} = "t";
}

while(<ALLOWED>){
	$line = $_;
	chomp $line;
	$line = uc($line);
	$allowedHash{$line} = "t";
}

$pickWord = int(rand($count));
$solution = $wordArr[$pickWord];
#$solution = "MOWER";
#print "$solution\n";
@solution = split(//, $solution);
#print "STOOP\n";
#@solution = split(//, "STOOP");
$guesses = 6;

if ($mode eq "all"){
	@gameScores;
	foreach $solution (@wordArr){
		@solution = split(//, $solution);
		$gameScore = main();
		$gameScores[$gameScore]++;
		@contains = ();
		@exclude = ();
		@positions = ();
		@possible = ();
		$guesses = 6;
		
	}
	print "\nLost: $gameScores[0]\nOnes: $gameScores[1]\nTwos: $gameScores[2]\nThrees: $gameScores[3]\nFours: $gameScores[4]\nFives: $gameScores[5]\nSixes: $gameScores[6]\n";	
} else {
	main();
}

sub main(){
	while($guesses > 0){
		print "Enter your guess:\n\t";
		if ($selection =~ /bot/){
			if ($guesses == 5 && $selection eq "dadbot"){
				$guess = "CRONY";
				print "CRONY\n";
			} else {
				$guess = bot();
			}
		} else {
			$guess = <STDIN>;
		}
		chomp $guess;
		$guess = uc($guess);
		if (checkGuess()){
			$guesses--;
			if ($mode eq "feedback"){
				print "\t";
				$feedback = <STDIN>;
				chomp $feedback;
				manualFeedback($feedback);
			} else {
				$feedback = compareGuess();
			}
			if ($feedback eq "!!!!!"){
				$used = 6 - $guesses;
				print "Correct! You used $used/6 guesses!";
				return $used;
			} else {
				print "\t$feedback\t$guesses guesses remaining!\n";
			}
		} else {
			print "Not a valid guess!\n";
			next;
		}
	}
	print "You lose! The word was $solution\n";
	return 0;
}

sub checkGuess() {
	$str_len = length($guess);
	#print "word is $str_len letters long\n";
	if($str_len == 5 && (exists($allowedHash{$guess}) || exists($wordHash{$guess}))){
		#print "returning 1\n";
		return 1;
	} else {
		return 0;
	}
}

sub manualFeedback() {
	@feedbackArr = split(//, $_[0]);
	@guessArr = split(//, $guess);
	$guessSoFar = "";
	for(my $i = 0; $i < 5; $i++) {
		if ($feedbackArr[$i] eq "!") {
			push(@contains, $guessArr[$i]);
			$positions[$i] = "!$guessArr[$i]";
			$guessSoFar .= "$guessArr[$i]";
			@exclude = grep { $_ ne $guessArr[$i] } @exclude;
		} elsif ($feedbackArr[$i] eq "~"){
			push(@contains, $guessArr[$i]);
			$positions[$i] .= "~$guessArr[$i]";
			$guessSoFar .= "$guessArr[$i]";
			@exclude = grep { $_ ne $guessArr[$i] } @exclude;
		} else { #Not perfect, needs to be updated
			unless ($guessSoFar =~ /$guessArr[$i]/){
				push(@exclude, $guessArr[$i]);
				$positions[$i] .= "~$guessArr[$i]";
			} else {
				$positions[$i] .= "~$guessArr[$i]";
			}
			$guessSoFar .= "$guessArr[$i]";
		}
	}
}

sub compareGuess(){
	@guessArr = split(//, $guess);
	my @feedbackArr = ("-", "-", "-", "-", "-");
	my %letterHash;
	$doubleFlag = 0;
	for (my $i = 0; $i < 5; $i++){
		for (my $j = 0; $j < 5; $j++){
			#print "i: $i j: $j\n";
			if($guessArr[$i] eq $solution[$j] && $i == $j){
				$feedbackArr[$i] = "!";
				if ($letterHash{$guessArr[$i]} =~ /$j!/){
					@separate = split(/!/, $letterHash{$guessArr[$i]});
					$feedbackArr[$separate[1]] = "-";
				}
				push(@contains, $guessArr[$i]);
				$positions[$i] = "!$guessArr[$i]";
				$letterHash{$guessArr[$i]} = "$j!$i";
				last;
			} elsif ($guessArr[$i] eq $solution[$j]){
				if($letterHash{$guessArr[$i]} =~ /$j!/){
					$doubleFlag = 1;
					#print "skipping!\n";
					next;
				}
				$feedbackArr[$i] = "~";
				$letterHash{$guessArr[$i]} = "$j!$i";
				push(@contains, $guessArr[$i]);
				unless ($positions[$i] =~ /!/){
					$positions[$i] .= "~$guessArr[$i]";
				}
			}
		}
	}
	
	for (my $i = 0; $i < 5; $i++){
		if ($feedbackArr[$i] eq "-" && !(exists($letterHash{$guessArr[$i]}))){
			push(@exclude, $guessArr[$i]);
		} elsif ($feedbackArr[$i] eq "-" && $doubleFlag == 0){
			for(my $j = 0; $j < 5; $j++){
				unless ($positions[$j] =~ /!/){
					$positions[$j] .= "~$guessArr[$i]";
				}
			}
		} elsif ($feedbackArr[$i] eq "-"){
			$positions[$i] .= "~$guessArr[$i]";
		}
	}
	$output = "$feedbackArr[0]$feedbackArr[1]$feedbackArr[2]$feedbackArr[3]$feedbackArr[4]";
	return $output;
}

sub bot(){
	my %zeroF;
	my %firstF;
	my %secondF;
	my %thirdF;
	my %fourthF;
	my @validWords;
	my $validCount = 0;
	
	foreach $word (@wordArr){ #creates array of valid words
		$validFlag = 1;
		foreach $entry (@contains){
			unless ($word =~ /$entry/){
				$validFlag = 0;
			}
		}
		foreach $entry (@exclude) {
			if ($word =~ /$entry/){
				$validFlag = 0;
			}
		}
		@wordLetters = split(//, $word);
		for (my $i = 0; $i < 5; $i++){
			if ($positions[$i] =~ /!/) {
				$letter = $positions[$i];
				$letter =~ s/!//;
				unless ($wordLetters[$i] eq $letter){
					$validFlag = 0;
				}
			} elsif ($positions[$i] =~ /~/){
				@letters = split(/~/, $positions[$i]);
				foreach $letter (@letters){
					if ($wordLetters[$i] eq $letter){
						$validFlag = 0;
					}
				}
			}
		}
		
		if ($validFlag == 1){
			push(@validWords, $word);
			@letters = split(//, $word);
			$zeroF{$letters[0]}++;
			$firstF{$letters[1]}++;
			$secondF{$letters[2]}++;
			$thirdF{$letters[3]}++;
			$fourthF{$letters[4]}++;
			$validCount++;
		}
	}
	
	$maxScore = 0;
	$savedWord = "SAVED";
	foreach $word (@validWords){
		@letters = split(//, $word);
		$score = $zeroF{$letters[0]}+$firstF{$letters[1]}+$secondF{$letters[2]}+$thirdF{$letters[3]}+$fourthF{$letters[4]};
		if($score > $maxScore){
			$maxScore = $score;
			$savedWord = $word;
		}
	}
	
	$numLett = 0;
	foreach $entry (@positions){
		if ($entry =~ /!/){
			$numLett++;
		}
	}
	if(($numLett >= 4 && $validCount > $guesses)){ #if in a BOUND, MOUND, FOUND, etc. situation
		@possible = ();
		$maxScore = 0;
		for (my $i = 0; $i < 5; $i++){
			if (!($positions[$i] =~ /!/)){
				foreach $word (@validWords){
					@letters = split(//,$word);
					push(@possible, $letters[$i]);
				}
			}
		}
		foreach $word (keys %allowedHash){
			$score = 0;
			foreach $letter (@possible){
				if ($word =~ /$letter/){
					$score++;
				}
			}
			if ($score > $maxScore){
				$maxScore = $score;
				$savedWord = $word;
			}
		}
	}
	
	print "$savedWord\t$validCount valid words\n"; #can also print out positions array here
	return $savedWord;
}
describe package('memb') do
  it { should be_installed }
end

describe package('tinydns') do
  it { should be_installed }
  its('version') { should eq '0.3-1' }
end

describe package('coin-or-coinutils') do
  it { should be_installed }
end

describe package('coq') do
  it { should_not be_installed }
end

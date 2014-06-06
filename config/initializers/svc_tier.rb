module SvcTier
  if Rails.env == 'development'
    if Socket.gethostname =~ /srch-sa01/i
      Base_Url = 
        'http://ngmw-dod-qa01.sv.walmartlabs.com:4000'
    else
      Base_Url = 'http://localhost:4000'
    end
  else
    Base_Url = 'http://ngmw-dod-qa00.sv.walmartlabs.com:4000'
  end
end

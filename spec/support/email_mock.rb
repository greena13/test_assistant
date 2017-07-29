class EmailMock
  attr_reader :to, :from, :subject, :text, :body

  def initialize(to: 'receiver@email.com', from: 'sender@email.com', subject: 'Subject', text: 'Email', body: "<body><h1>Email</h1><a href='www.test.com' /><img src='www.test.com' /></body>")
    @to, @from, @subject, @text, @body = to, from, subject, text, body
  end

  def parts
    [
       EmailBodyMock.new(@body)
    ]
  end
end

class EmailBodyMock
  def initialize(text)
    @text = text
  end

  def body
    self
  end

  def decoded
    @text
  end
end

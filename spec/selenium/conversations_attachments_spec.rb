require File.expand_path(File.dirname(__FILE__) + '/helpers/conversations_common')

shared_examples_for "conversations attachments selenium tests" do
  it_should_behave_like "forked server selenium tests"
  it_should_behave_like "conversations selenium tests"

  it "should be able to add an attachment to the message form" do
    filename, fullpath, data = get_file("testfile1.txt")
    new_conversation

    new_conversation
    submit_message_form(:attachments => [fullpath])
    @user.conversations.last.has_attachments.should be_true
    @user.conversation_attachments_folder.attachments.count.should == 1
  end

  it "should be able to add multiple attachments to the message form" do
    filename1, fullpath1, data1 = get_file("testfile1.txt")
    filename2, fullpath2, data2 = get_file("testfile2.txt")
    filename3, fullpath3, data3 = get_file("testfile3.txt")
    new_conversation

    add_attachment_link = f("#action_add_attachment")
    add_attachment_link.click
    wait_for_animations
    ffj("#create_message_form .file_input:visible")[0].send_keys(fullpath1)
    add_attachment_link.click
    wait_for_animations
    ffj("#create_message_form .file_input:visible")[1].send_keys(fullpath2)
    add_attachment_link.click
    wait_for_animations
    ffj("#create_message_form .file_input:visible")[2].send_keys(fullpath3)
    ffj("#attachment_list > .attachment:visible").size.should == 3
    submit_message_form
    @user.conversation_attachments_folder.attachments.count.should == 3
  end

  it "should be able to remove attachments from the message form" do
    new_conversation

    add_attachment_link = f("#action_add_attachment")
    add_attachment_link.click
    wait_for_animations
    add_attachment_link.click
    wait_for_animations
    ffj("#attachment_list > .attachment:visible .remove_link")[1].click
    wait_for_animations
    ffj("#attachment_list > .attachment:visible").size.should == 1
    ffj("#attachment_list > .attachment:visible .remove_link")[0].click
    submit_message_form
    @user.conversations.last.has_attachments.should be_false
  end

  it "should save just one attachment when sending a bulk private message" do
    student_in_course
    @course.enroll_user(User.create(:name => "student1"))
    @course.enroll_user(User.create(:name => "student2"))
    @course.enroll_user(User.create(:name => "student3"))

    filename, fullpath, data = get_file("testfile1.txt")
    new_conversation
    add_recipient("student1")
    add_recipient("student2")
    add_recipient("student3")
    expect {
      submit_message_form(:attachments => [fullpath], :add_recipient => false, :group_conversation => false)
    }.to change(Attachment, :count).by(1)
  end

  it "should save attachments on new messages on existing conversations" do
    student_in_course
    filename, fullpath, data = get_file("testfile1.txt")

    new_conversation
    submit_message_form

    message = submit_message_form(:attachments => [fullpath])
    message = "#message_#{message.id}"

    ffj("#{message} .message_attachments li").size.should == 1
  end

  it "should save multiple attachments" do
    student_in_course
    file1 = get_file("testfile1.txt")
    file2 = get_file("testfile2.txt")

    new_conversation
    message = submit_message_form(:attachments => [file1[1], file2[1]])
    message = "#message_#{message.id}"

    ffj("#{message} .message_attachments li").size.should == 2
    fj("#{message} .message_attachments li:first a .title").text.should == file1[0]
    fj("#{message} .message_attachments li:last a .title").text.should == file2[0]
  end

  it "should show forwarded attachments" do
    student_in_course
    @course.enroll_user(User.create(:name => 'student1'))
    @course.enroll_user(User.create(:name => 'student2'))

    filename, fullpath, data = get_file('testfile1.txt')
    new_conversation
    add_recipient('student1')
    submit_message_form(:attachments => [fullpath], :add_recipient => false)

    get_messages(false).first.click
    wait_for_animations
    f('#action_forward').click

    add_recipient('student2', 'forward_recipients')
    f('#forward_body').send_keys('ohai look an attachment')
    f('#forward_message_form').submit

    wait_for_ajaximations

    ff('img.attachments').size.should eql 2
    messages = get_messages(false) # new conversation auto-selected
    messages.size.should == 1
    messages.first.text.should include "ohai look an attachment"
    messages.first.text.should include filename
  end
end

describe "conversations attachments local tests" do
  it_should_behave_like "conversations attachments selenium tests"
  prepend_before (:each) do
    Setting.set("file_storage_test_override", "local")
  end
  prepend_before (:all) do
    Setting.set("file_storage_test_override", "local")
  end

  it "should save attachments on initial messages on new conversations" do
    pending('connection refused - connect(2) - line 108')
    student_in_course
    filename, fullpath, data = get_file("testfile1.txt")

    new_conversation
    message = submit_message_form(:attachments => [fullpath])
    message = "#message_#{message.id}"

    ffj("#{message} .message_attachments li").size.should == 1
    fj("#{message} .message_attachments li a .title").text.should == filename
    download_link = f("#{message} .message_attachments li a")
    keep_trying_until do
      file = open(download_link.attribute('href'))
      file.read.should match data
    end
  end

end

describe "conversations attachments S3 tests" do
  it_should_behave_like "conversations attachments selenium tests"
  prepend_before (:each) do
    Setting.set("file_storage_test_override", "s3")
  end
  prepend_before (:all) do
    Setting.set("file_storage_test_override", "s3")
  end
end

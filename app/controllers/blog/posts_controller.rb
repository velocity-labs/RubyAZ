class Blog::PostsController < BlogController

  before_filter :find_all_blog_posts, :except => [:archive]
  before_filter :find_blog_post, :only => [:show, :comment, :update_nav]

  respond_to :html, :js, :rss

  def index
    respond_with (@blog_posts) do |format|
      format.html
      format.rss
    end
  end

  def show
    @blog_comment = BlogComment.new

    respond_with (@blog_post) do |format|
      format.html { present(@page) }
      format.js { render :partial => 'post', :layout => false }
    end
  end 
  
  def comment
    @blog_comment = BlogComment.new(params[:blog_comment])
    @blog_comment.post = @blog_post

    if verify_recaptcha(:model => @blog_comment, :message => 'Invalid reCAPTCHA!') && @blog_comment.valid?
      @blog_comment.save
      if BlogComment::Moderation.enabled?
        flash[:notice] = t('blog.posts.comments.thank_you_moderated')
        redirect_to blog_post_url(params[:id])
      else
        flash[:notice] = t('blog.posts.comments.thank_you')
        redirect_to blog_post_url(params[:id],
                                  :anchor => "comment-#{@blog_comment.to_param}")
      end
    else
      render :action => 'show'
    end
  end  

  def archive
    if params[:month].present?
      date = "#{params[:month]}/#{params[:year]}"
      @archive_date = Time.parse(date)
      @date_title = @archive_date.strftime('%B %Y')
      @blog_posts = BlogPost.live.by_archive(@archive_date).paginate({
        :page => params[:page],
        :per_page => RefinerySetting.find_or_set(:blog_posts_per_page, 10)
      })
    else
      date = "01/#{params[:year]}"
      @archive_date = Time.parse(date)
      @date_title = @archive_date.strftime('%Y')
      @blog_posts = BlogPost.live.by_year(@archive_date).paginate({
        :page => params[:page],
        :per_page => RefinerySetting.find_or_set(:blog_posts_per_page, 10)
      })
    end
    respond_with (@blog_posts)
  end

protected

  def find_blog_post
    if (@blog_post = BlogPost.find(params[:id])).try(:draft) # changed from :live? to allow future posts
      if refinery_user? and current_user.authorized_plugins.include?("refinerycms_blog")
        @blog_post = BlogPost.find(params[:id])
      else
        error_404
      end
    end
  end

  def find_all_blog_posts
    @blog_posts = BlogPost.non_drafts.includes(:comments, :categories).paginate({
      :page => params[:page],
      :per_page => RefinerySetting.find_or_set(:blog_posts_per_page, 10)
    })
  end

end

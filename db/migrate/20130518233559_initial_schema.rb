class InitialSchema < ActiveRecord::Migration
  def change
    create_table :users do |t|

      t.string :nickname, null: false, default: ""

      ## Database authenticatable
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      
      ## Rememberable
      t.datetime :remember_created_at
      
      ## Trackable
      t.integer  :sign_in_count, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      
      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email
        
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token, unique: true
    
    create_table :posts do |t|
      t.belongs_to :author
      t.string :title
      t.text :body
      t.timestamp :body_updated_at
      t.string :url
      t.timestamp :latest_reply_at
      t.integer :total_replies_count, default: 0
      
      t.timestamps
    end
    add_index :posts, :author_id
    
    create_table :comments do |t|
      t.belongs_to :author
      t.belongs_to :commentable, polymorphic: true
      t.text :body
      t.timestamp :body_updated_at
      t.timestamp :latest_reply_at
      t.integer :total_replies_count, default: 0

      t.timestamps
    end
    add_index :comments, [:commentable_id, :commentable_type]
  end
end

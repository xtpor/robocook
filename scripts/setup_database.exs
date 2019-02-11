
:mnesia.create_schema([node()])
:mnesia.start

:mnesia.create_table(:user_info, [disc_copies: [node()], attributes: [:username, :password]])
:mnesia.create_table(:user_savedata, [disc_copies: [node()], attributes: [:user_ref, :data]])

"""empty message

Revision ID: 2b768b11553e
Revises: d532a371825d
Create Date: 2018-07-12 23:38:25.471688

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '2b768b11553e'
down_revision = 'd532a371825d'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('user', sa.Column('is_comment_notification', sa.Boolean(), nullable=True))
    op.add_column('user', sa.Column('is_shift_import_notification', sa.Boolean(), nullable=True))
    op.add_column('user', sa.Column('is_update_shift_notification', sa.Boolean(), nullable=True))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('user', 'is_update_shift_notification')
    op.drop_column('user', 'is_shift_import_notification')
    op.drop_column('user', 'is_comment_notification')
    # ### end Alembic commands ###

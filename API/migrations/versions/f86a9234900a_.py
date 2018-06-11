"""empty message

Revision ID: f86a9234900a
Revises: 4dfd9e2b9078
Create Date: 2018-04-03 01:57:13.409002

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'f86a9234900a'
down_revision = '4dfd9e2b9078'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('colorscheme', sa.Column('created_at', sa.DateTime(), nullable=False))
    op.add_column('colorscheme', sa.Column('updated_at', sa.DateTime(), nullable=False))
    op.add_column('history', sa.Column('updated_at', sa.DateTime(), nullable=False))
    op.add_column('role', sa.Column('created_at', sa.DateTime(), nullable=False))
    op.add_column('role', sa.Column('updated_at', sa.DateTime(), nullable=False))
    op.add_column('salary', sa.Column('created_at', sa.DateTime(), nullable=False))
    op.add_column('salary', sa.Column('updated_at', sa.DateTime(), nullable=False))
    op.add_column('shift', sa.Column('created_at', sa.DateTime(), nullable=False))
    op.add_column('shift', sa.Column('updated_at', sa.DateTime(), nullable=False))
    op.add_column('shiftcategory', sa.Column('created_at', sa.DateTime(), nullable=False))
    op.add_column('shiftcategory', sa.Column('updated_at', sa.DateTime(), nullable=False))
    op.add_column('shifttable', sa.Column('created_at', sa.DateTime(), nullable=False))
    op.add_column('shifttable', sa.Column('updated_at', sa.DateTime(), nullable=False))
    op.add_column('usershift', sa.Column('created_at', sa.DateTime(), nullable=False))
    op.add_column('usershift', sa.Column('updated_at', sa.DateTime(), nullable=False))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('usershift', 'updated_at')
    op.drop_column('usershift', 'created_at')
    op.drop_column('shifttable', 'updated_at')
    op.drop_column('shifttable', 'created_at')
    op.drop_column('shiftcategory', 'updated_at')
    op.drop_column('shiftcategory', 'created_at')
    op.drop_column('shift', 'updated_at')
    op.drop_column('shift', 'created_at')
    op.drop_column('salary', 'updated_at')
    op.drop_column('salary', 'created_at')
    op.drop_column('role', 'updated_at')
    op.drop_column('role', 'created_at')
    op.drop_column('history', 'updated_at')
    op.drop_column('colorscheme', 'updated_at')
    op.drop_column('colorscheme', 'created_at')
    # ### end Alembic commands ###
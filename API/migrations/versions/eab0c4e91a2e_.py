"""empty message

Revision ID: eab0c4e91a2e
Revises: 461e8be32672
Create Date: 2018-04-15 01:33:06.304831

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'eab0c4e91a2e'
down_revision = '461e8be32672'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('usershift', sa.Column('memo', sa.String(length=255), nullable=True))
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('usershift', 'memo')
    # ### end Alembic commands ###

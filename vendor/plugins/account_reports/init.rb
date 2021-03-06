#
# Copyright (C) 2012 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

require 'canvas/account_reports'
require 'canvas/account_reports/default'

Rails.configuration.to_prepare do
  Canvas::AccountReports.add_account_reports 'default', 'Default', {
    'student_assignment_outcome_map_csv'=> {
      :title => 'Student Competency',
      :description_partial => true,
    },
    'grade_export_csv'=> {
      :title => 'Grade Export',
      :description_partial => true,
      :parameters_partial => true,
      :parameters => {
        :enrollment_term => {
          :required => true,
          :description => 'The canvas id of the term to get grades from'
        }
      }
    },
    'sis_export_csv'=> {
      :title => 'SIS Export',
      :parameters_partial => true,
      :parameters => {
        :users => {
          :description => 'Get the SIS file for users'
        },
        :accounts => {
          :description => 'Get the SIS file for accounts'
        },
        :terms => {
          :description => 'Get the SIS file for terms'
        },
        :courses => {
          :description => 'Get the SIS file for courses'
        },
        :sections => {
          :description => 'Get the SIS file for sections'
        },
        :enrollments => {
          :description => 'Get the SIS file for enrollments'
        },
        :groups => {
          :description => 'Get the SIS file for groups'
        },
        :group_membership => {
          :description => 'Get the SIS file for group_membership'
        },
        :xlist => {
          :description => 'Get the SIS file for cross listed courses'
        },
      }
    }
  }
end

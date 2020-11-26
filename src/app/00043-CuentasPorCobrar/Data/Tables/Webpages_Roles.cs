using Dapper;
using Data.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Data.Tables
{
    public class Webpages_Roles
    {
        public int RoleId { get; set; }
        public string RoleName { get; set; }


        public List<Webpages_Roles> Find()
        {
            List<Webpages_Roles> result = new List<Webpages_Roles>();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT RoleId, RoleName FROM webpages_Roles;";

                    result = _dbConnection.Query<Webpages_Roles>(s_command, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;

        }


        public Webpages_Roles FindByUserId(int userId)
        {
            Webpages_Roles result = new Webpages_Roles();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    string s_command = @"SELECT R.RoleId, R.RoleName FROM webpages_UsersInRoles UR 
                                        INNER JOIN  webpages_Roles R ON UR.RoleId = R.RoleId 
                                        WHERE UR.UserId = @UserId;";

                    result = _dbConnection.QueryFirstOrDefault<Webpages_Roles>(s_command, new { UserId = userId }, commandType: CommandType.Text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;

        }
    }
}

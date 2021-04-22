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
    public class TI_ConceptoCategoriaPago
    {
        public int? I_CatPagoID { get; set; }
        public int? I_ConceptoID { get; set; }
        public string T_CatPagoDesc { get; set; }
        public string T_ConceptoDesc { get; set; }
        public string T_Clasificador { get; set; }
        public decimal I_Monto { get; set; }
        public decimal I_MontoMinimo { get; set; }



        public List<TI_ConceptoCategoriaPago> FindByCategoriaID(int categoriaPagoID)
        {
            List<TI_ConceptoCategoriaPago> result;

            try
            {
                string s_command = @"SELECT CCP.*, CP.T_CatPagoDesc, C.T_ConceptoDesc, C.I_Monto, C.I_MontoMinimo, C.T_Clasificador 
                                     FROM dbo.TC_CategoriaPago CP
 	                                     INNER JOIN dbo.TI_ConceptoCategoriaPago CCP ON CP.I_CatPagoID = CCP.I_CatPagoID
 	                                     INNER JOIN dbo.TC_Concepto C ON C.I_ConceptoID = CCP.I_ConceptoID
                                     WHERE CCP.I_CatPagoID = @I_CatPagoID";

                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    result = _dbConnection.Query<TI_ConceptoCategoriaPago>(s_command, new { I_CatPagoID = categoriaPagoID }, commandType: CommandType.Text).ToList();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        public ResponseData Save(DataTable dataTable)
        {
            ResponseData result = new ResponseData();
            DynamicParameters parameters = new DynamicParameters();

            try
            {
                using (var _dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    parameters.Add(name: "I_CatPagoID", dbType: DbType.Int32, value: this.I_CatPagoID);
                    parameters.Add(name: "Tbl_Conceptos", value: dataTable.AsTableValuedParameter("type_SelectItems"));

                    parameters.Add(name: "B_Result", dbType: DbType.Boolean, direction: ParameterDirection.Output);
                    parameters.Add(name: "T_Message", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                    _dbConnection.Execute("USP_IU_GrabarConceptosCategoriaPago", parameters, commandType: CommandType.StoredProcedure);

                    result.Value = parameters.Get<bool>("B_Result");
                    result.Message = parameters.Get<string>("T_Message");
                }
            }
            catch (Exception ex)
            {
                result.Value = false;
                result.Message = ex.Message;
            }

            return result;
        }
    }
}

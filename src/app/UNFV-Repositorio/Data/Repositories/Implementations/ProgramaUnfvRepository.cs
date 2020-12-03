using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.Connection;
using Data.DTO;
using Data.Procedures;
using Data.Tables;
using Data.Views;

namespace Data.Repositories.Implementations
{
    public class ProgramaUnfvRepository : IProgramaUnfvRepository
    {
        public ResponseData Create(USP_I_GrabarCarreraProfesional paramGrabarCarreraProfesional, USP_I_GrabarProgramaUnfv paramGrabarProgramaUnfv)
        {
            ResponseData result;

            try
            {
                using (var dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    dbConnection.Open();

                    using (var dbTransaction = dbConnection.BeginTransaction())
                    {
                        if (paramGrabarCarreraProfesional != null)
                        {
                            USP_I_GrabarCarreraProfesional.Execute(dbConnection, dbTransaction, paramGrabarCarreraProfesional);
                        }

                        USP_I_GrabarProgramaUnfv.Execute(dbConnection, dbTransaction, paramGrabarProgramaUnfv);

                        dbTransaction.Commit();
                    }
                }

                result = new ResponseData()
                {
                    Value = true,
                    Message = "Los datos del Programa fueron grabados correctamente."
                };
            }
            catch (Exception ex)
            {
                result = new ResponseData()
                {
                    Value = false,
                    Message = ex.Message
                };
            }

            return result;
        }

        public ResponseData Edit(USP_U_ActualizarCarreraProfesional paramActualizarCarreraProfesional, USP_U_ActualizarProgramaUnfv paramActualizarProgramaUnfv)
        {
            ResponseData result;

            try
            {
                using (var dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    dbConnection.Open();

                    using (var dbTransaction = dbConnection.BeginTransaction())
                    {
                        var resultGrabarCarreraProfesional = USP_U_ActualizarCarreraProfesional.Execute(dbConnection, dbTransaction, paramActualizarCarreraProfesional);

                        var resultGrabarProgramaUnfv = USP_U_ActualizarProgramaUnfv.Execute(dbConnection, dbTransaction, paramActualizarProgramaUnfv);

                        dbTransaction.Commit();
                    }
                }

                result = new ResponseData()
                {
                    Value = true,
                    Message = "Los datos del Programa fueron actualizados correctamente."
                };
            }
            catch (Exception ex)
            {
                result = new ResponseData()
                {
                    Value = false,
                    Message = ex.Message
                };
            }

            return result;
        }

        public IEnumerable<VW_ProgramaUnfv> GetAll()
        {
            IEnumerable<VW_ProgramaUnfv> result;
            try
            {
                result = VW_ProgramaUnfv.GetAll();
            }
            catch (Exception)
            {
                result = null;
            }

            return result;
        }

        public VW_ProgramaUnfv GetByID(string codProg)
        {
            VW_ProgramaUnfv result;
            try
            {
                result = VW_ProgramaUnfv.GetByID(codProg);
            }
            catch (Exception)
            {
                result = null;
            }

            return result;
        }

        public VW_ProgramaUnfv GetByCodRc(string codRc)
        {
            VW_ProgramaUnfv result;
            try
            {
                result = VW_ProgramaUnfv.GetByCodRc(codRc);
            }
            catch (Exception)
            {
                result = null;
            }

            return result;
        }
    }
}

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
    public class AlumnoRepository : IAlumnoRepository
    {
        public ResponseData Create(USP_I_GrabarPersona paramGrabarPersona, USP_I_GrabarAlumno paramGrabarAlumno)
        {
            ResponseData result;

            try
            {
                using (var dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    dbConnection.Open();

                    using (var dbTransaction = dbConnection.BeginTransaction())
                    {
                        if (paramGrabarAlumno.I_PersonaID == 0)
                        {
                            var resultGrabarPersona = USP_I_GrabarPersona.Execute(dbConnection, dbTransaction, paramGrabarPersona);

                            paramGrabarAlumno.I_PersonaID = int.Parse(resultGrabarPersona.CurrentID);
                        }

                        var resultGrabarAlumno = USP_I_GrabarAlumno.Execute(dbConnection, dbTransaction, paramGrabarAlumno);

                        dbTransaction.Commit();
                    }
                }

                result = new ResponseData()
                {
                    Value = true,
                    Message = "Los datos del alumno fueron grabados correctamente."
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

        public ResponseData Edit(USP_U_ActualizarPersona paramActualizarPersona, USP_U_ActualizarAlumno paramActualizarAlumno)
        {
            ResponseData result;

            try
            {
                using (var dbConnection = new SqlConnection(Database.ConnectionString))
                {
                    dbConnection.Open();

                    using (var dbTransaction = dbConnection.BeginTransaction())
                    {
                        var resultGrabarPersona = USP_U_ActualizarPersona.Execute(dbConnection, dbTransaction, paramActualizarPersona);

                        var resultGrabarAlumno = USP_U_ActualizarAlumno.Execute(dbConnection, dbTransaction, paramActualizarAlumno);

                        dbTransaction.Commit();
                    }
                }

                result = new ResponseData()
                {
                    Value = true,
                    Message = "Los datos del alumno fueron actualizados correctamente."
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

        public IEnumerable<VW_Alumnos> GetAll()
        {
            IEnumerable<VW_Alumnos> result;
            try
            {
                result = VW_Alumnos.GetAll();
            }
            catch (Exception)
            {
                result = null;
            }

            return result;
        }

        public VW_Alumnos GetByID(string codRc, string codAlu)
        {
            VW_Alumnos result;
            try
            {
                result = VW_Alumnos.GetByID(codRc, codAlu);
            }
            catch (Exception)
            {
                result = null;
            }

            return result;
        }

        public IEnumerable<VW_Alumnos> GetByDocIdent(string codTipDoc, string numDNI)
        {
            IEnumerable<VW_Alumnos> result;
            try
            {
                result = VW_Alumnos.GetByDocIdent(codTipDoc, numDNI);
            }
            catch (Exception)
            {
                result = null;
            }

            return result;
        }
    }
}

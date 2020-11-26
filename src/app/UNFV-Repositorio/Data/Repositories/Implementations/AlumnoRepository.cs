﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Data.DTO;
using Data.Procedures;
using Data.Tables;

namespace Data.Repositories.Implementations
{
    public class AlumnoRepository : IAlumnoRepository
    {
        public ResponseData Create(TC_Alumno alumno)
        {
            USP_I_GrabarAlumno procedimiento;
            ResponseData result;

            try
            {
                procedimiento = new USP_I_GrabarAlumno()
                {
                    
                };

                result = procedimiento.Execute();
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

        public ResponseData Edit(TC_Alumno alumno)
        {
            USP_U_ActualizarAlumno procedimiento;
            ResponseData result;

            try
            {
                procedimiento = new USP_U_ActualizarAlumno()
                {

                };

                result = procedimiento.Execute();
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

        public IEnumerable<TC_Alumno> GetAll()
        {
            IEnumerable<TC_Alumno> result;
            try
            {
                result = TC_Alumno.GetAll();
            }
            catch (Exception)
            {
                result = null;
            }

            return result;
        }

        public TC_Alumno GetByID(string C_RcCod, string C_CodAlu)
        {
            TC_Alumno result;
            try
            {
                result = TC_Alumno.GetByID(C_RcCod, C_CodAlu);
            }
            catch (Exception)
            {
                result = null;
            }

            return result;
        }
    }
}

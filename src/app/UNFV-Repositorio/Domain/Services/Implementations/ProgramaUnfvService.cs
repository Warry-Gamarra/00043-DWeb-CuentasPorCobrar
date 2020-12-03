using Data.DTO;
using Data.Repositories;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class ProgramaUnfvService : IProgramaUnfvService
    {
        IProgramaUnfvRepository _programaRepository;
        ICarreraProfesionalRepository _carreraProfesionalRepository;

        public ProgramaUnfvService(
            IProgramaUnfvRepository programaRepository,
            ICarreraProfesionalRepository carreraProfesionalRepository)
        {
            _programaRepository = programaRepository;
            _carreraProfesionalRepository = carreraProfesionalRepository;
        }

        public ServiceResponse Create(ProgramaUnfvEntity programaUnfvEntity)
        {
            ResponseData responseData;

            try
            {
                var programaUnfvPorCodRc = _programaRepository.GetByCodRc(programaUnfvEntity.C_RcCod);

                if (programaUnfvPorCodRc != null)
                {
                    throw new Exception("El Cod_Rc se repite en el sistema.");
                }

                var programaUnfvPorCodProg = _programaRepository.GetByID(programaUnfvEntity.C_CodProg);

                if (programaUnfvPorCodProg != null)
                {
                    throw new Exception("El Código de Programa se repite en el sistema.");
                }

                var carreraUnfv = _carreraProfesionalRepository.GetByID(programaUnfvEntity.C_RcCod);

                var paramGrabarCarreraProfesional = (carreraUnfv != null) ? null : Mapper.AlumnoEntity_To_USP_I_GrabarCarreraProfesional(programaUnfvEntity);

                var paramGrabarProgramaUnfv = Mapper.AlumnoEntity_To_USP_I_GrabarProgramaUnfv(programaUnfvEntity);

                responseData = _programaRepository.Create(paramGrabarCarreraProfesional, paramGrabarProgramaUnfv);
            }
            catch (Exception ex)
            {
                responseData = new ResponseData()
                {
                    Value = false,
                    Message = ex.Message
                };
            }

            return new ServiceResponse(responseData);
        }

        public ServiceResponse Edit(ProgramaUnfvEntity programaUnfvEntity)
        {
            ResponseData responseData;

            try
            {
                var carreraUnfv = _carreraProfesionalRepository.GetByID(programaUnfvEntity.C_RcCod);

                if (carreraUnfv == null)
                {
                    throw new Exception("El Cod_Rc no existe en el sistema.");
                }

                var programaUnfvPorCodProg = _programaRepository.GetByID(programaUnfvEntity.C_CodProg);

                if (programaUnfvPorCodProg == null)
                {
                    throw new Exception("El Programa no existe en el sistema.");
                }

                var programaUnfvPorCodRc = _programaRepository.GetByCodRc(programaUnfvEntity.C_RcCod);

                if (programaUnfvPorCodRc != null && programaUnfvPorCodRc.C_CodProg != programaUnfvEntity.C_RcCod)
                {
                    throw new Exception("El Cod_Rc se repite en el sistema.");
                }

                var paramGrabarCarreraProfesional = Mapper.AlumnoEntity_To_USP_U_ActualizarCarreraProfesional(programaUnfvEntity);

                var paramGrabarProgramaUnfv = Mapper.AlumnoEntity_To_USP_U_ActualizarProgramaUnfv(programaUnfvEntity);

                responseData = _programaRepository.Edit(paramGrabarCarreraProfesional, paramGrabarProgramaUnfv);
            }
            catch (Exception ex)
            {
                responseData = new ResponseData()
                {
                    Value = false,
                    Message = ex.Message
                };
            }

            return new ServiceResponse(responseData);
        }

        public IEnumerable<ProgramaUnfvDTO> GetAll()
        {
            IEnumerable<ProgramaUnfvDTO> result;

            var programas = _programaRepository.GetAll();

            if (programas == null)
                result = new List<ProgramaUnfvDTO>();
            else
            {
                result = programas.Select(p => Mapper.VW_ProgramaUnfv_To_ProgramaUnfvDTO(p));
            }

            return result;
        }

        public ProgramaUnfvDTO GetByID(string codProg)
        {
            var programa = _programaRepository.GetByID(codProg);

            var result = (programa == null) ? null : Mapper.VW_ProgramaUnfv_To_ProgramaUnfvDTO(programa);

            return result;
        }

        public ProgramaUnfvDTO GetByCodRc(string codRc)
        {
            var programa = _programaRepository.GetByCodRc(codRc);

            var result = (programa == null) ? null : Mapper.VW_ProgramaUnfv_To_ProgramaUnfvDTO(programa);

            return result;
        }
    }
}

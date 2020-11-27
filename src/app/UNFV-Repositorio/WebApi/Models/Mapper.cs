using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApi.Models
{
    public static class Mapper
    {
        public static FacultadModel FacultadDTO_To_FacultadModel(FacultadDTO facultadDTO)
        {
            if (facultadDTO == null)
                return null;

            FacultadModel facultadModel = new FacultadModel()
            {
                CodFac = facultadDTO.CodFac,
                FacDesc = facultadDTO.FacDesc,
                FacAbrev = facultadDTO.FacAbrev,
                Habilitado = facultadDTO.Habilitado
            };

            return facultadModel;
        }

        public static EscuelaModel EscuelaDTO_To_EscuelaModel(EscuelaDTO escuelaDTO)
        {
            if (escuelaDTO == null)
                return null;

            EscuelaModel escuelaModel = new EscuelaModel()
            {
                CodEsc = escuelaDTO.CodEsc,
                CodFac = escuelaDTO.CodFac,
                EscDesc = escuelaDTO.EscDesc,
                EscAbrev = escuelaDTO.EscAbrev,
                Habilitado = escuelaDTO.Habilitado
            };

            return escuelaModel;
        }

        public static EspecialidadModel EspecialidadDTO_To_EspecialidadModel(EspecialidadDTO especialidadDTO)
        {
            if (especialidadDTO == null)
                return null;

            EspecialidadModel especialidadModel = new EspecialidadModel()
            {
                CodEsp = especialidadDTO.CodEsp,
                CodEsc = especialidadDTO.CodEsc,
                CodFac = especialidadDTO.CodFac,
                EspDesc = especialidadDTO.EspDesc,
                EspAbrev = especialidadDTO.EspAbrev,
                Habilitado = especialidadDTO.Habilitado
            };

            return especialidadModel;
        }
    }
}
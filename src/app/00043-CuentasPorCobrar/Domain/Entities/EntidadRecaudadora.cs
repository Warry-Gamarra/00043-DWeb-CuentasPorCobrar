using Data.Tables;
using Domain.Helpers;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class EntidadRecaudadora : IEntidadRecaudadora
    {
        public int Id { get; set; }
        public string Nombre { get; set; }
        public bool Habilitado { get; set; }
        public bool ArchivosEntidad { get; set; }
        public DateTime? FechaActualiza { get; set; }
        public Response Response { get; set; }


        private readonly TC_EntidadFinanciera _entFinanRepository;
        private readonly TI_TipoArchivo_EntidadFinanciera _archivoEntFinanRepository;

        public EntidadRecaudadora()
        {
            _entFinanRepository = new TC_EntidadFinanciera();
            _archivoEntFinanRepository = new TI_TipoArchivo_EntidadFinanciera();
            this.Response = new Response() { Value = true };
        }

        public EntidadRecaudadora(TC_EntidadFinanciera table, bool tieneArchivos)
        {
            this.Id = table.I_EntidadFinanID;
            this.Nombre = table.T_EntidadDesc;
            this.Habilitado = table.B_Habilitado;
            this.ArchivosEntidad = tieneArchivos;
            this.FechaActualiza = table.D_FecMod ?? table.D_FecCre;
            this.Response = new Response() { Value = true };
        }

        public Response ChangeState(int entidadFinanId, bool currentState, int currentUserId)
        {
            _entFinanRepository.I_EntidadFinanID = entidadFinanId;
            _entFinanRepository.D_FecMod = DateTime.Now;
            _entFinanRepository.B_Habilitado = !currentState;

            return new Response(_entFinanRepository.ChangeState(currentUserId));
        }

        public List<EntidadRecaudadora> Find()
        {
            var result = new List<EntidadRecaudadora>();
            var archivosEntidad = _archivoEntFinanRepository.Find();
            foreach (var item in _entFinanRepository.Find())
            {
                bool tieneArchivos = ExisteListaArchivos(item.I_EntidadFinanID, archivosEntidad);
                result.Add(new EntidadRecaudadora(item, tieneArchivos));
            }

            return result;
        }

        public EntidadRecaudadora Find(int entidadRecaudadoraId)
        {
            var data = _entFinanRepository.Find(entidadRecaudadoraId);
            var archivosEntidad = _archivoEntFinanRepository.FindByEntityID(entidadRecaudadoraId);

            if (data != null)
            {
                bool tieneArchivos = ExisteListaArchivos(entidadRecaudadoraId, archivosEntidad); ;
                return new EntidadRecaudadora(data, tieneArchivos);
            }
            return new EntidadRecaudadora()
            {
                Response = new Response()
                {
                    Value = false,
                    Message = "No se encontraron resultados para el identificador de la entidad financiera."
                }
            };
        }

        public Response Save(EntidadRecaudadora entidadRecaudadora, int currentUserId, SaveOption saveOption)
        {
            _entFinanRepository.I_EntidadFinanID = entidadRecaudadora.Id;
            _entFinanRepository.T_EntidadDesc = entidadRecaudadora.Nombre;
            _entFinanRepository.B_Habilitado = entidadRecaudadora.Habilitado;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _entFinanRepository.D_FecCre = DateTime.Now;
                    return new Response(_entFinanRepository.Insert(entidadRecaudadora.ArchivosEntidad, currentUserId));

                case SaveOption.Update:
                    _entFinanRepository.D_FecMod = DateTime.Now;
                    return new Response(_entFinanRepository.Update(currentUserId));
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inválida."
            };
        }

        public Response HabilitarArchivos(int entidadRecaudadoraId, int currentUserId)
        {
            _archivoEntFinanRepository.I_EntidadFinanID = entidadRecaudadoraId;
            _archivoEntFinanRepository.I_UsuarioCre = currentUserId;
            _archivoEntFinanRepository.D_FecCre = DateTime.Now;

            return new Response(_archivoEntFinanRepository.HabilitarArchivosEntidadFinanciera());
        }


        private bool ExisteListaArchivos(int entidadRecaudadoraId, List<TI_TipoArchivo_EntidadFinanciera> archivosEntidad)
        {
            if (archivosEntidad.Where(x => x.I_EntidadFinanID == entidadRecaudadoraId).Count() > 0)
            {
                return true;
            }
            return false;
        }
    }
}
